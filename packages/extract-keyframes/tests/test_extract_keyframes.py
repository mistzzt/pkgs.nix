import importlib.util
import importlib.machinery
import json
import pathlib
import subprocess
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "extract-keyframes"


def load_module():
    loader = importlib.machinery.SourceFileLoader("extract_keyframes_cli", str(SCRIPT))
    spec = importlib.util.spec_from_loader("extract_keyframes_cli", loader)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class SceneBudgetTests(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def candidate(self, timestamp, score):
        return self.mod.Candidate(timestamp_seconds=timestamp, scene_score=score)

    def test_keeps_every_candidate_when_under_budget(self):
        candidates = [self.candidate(4.0, 0.01), self.candidate(2.0, 0.9)]

        selected = self.mod.select_scene_candidates(candidates, 10)

        self.assertEqual([c.timestamp_seconds for c in selected], [2.0, 4.0])

    def test_evicts_lowest_scores_first_and_returns_timestamp_order(self):
        candidates = [
            self.candidate(10.0, 0.10),
            self.candidate(20.0, 0.90),
            self.candidate(30.0, 0.50),
            self.candidate(40.0, 0.40),
        ]

        selected = self.mod.select_scene_candidates(candidates, 2)

        self.assertEqual(
            [(c.timestamp_seconds, c.scene_score) for c in selected],
            [(20.0, 0.90), (30.0, 0.50)],
        )

    def test_score_ties_keep_the_earlier_timestamp(self):
        candidates = [self.candidate(9.0, 0.5), self.candidate(3.0, 0.5)]

        selected = self.mod.select_scene_candidates(candidates, 1)

        self.assertEqual([c.timestamp_seconds for c in selected], [3.0])

    def test_zero_budget_selects_nothing(self):
        self.assertEqual(
            self.mod.select_scene_candidates([self.candidate(3.0, 0.5)], 0), []
        )


class GapFillTests(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def test_no_fill_when_all_gaps_are_within_max_gap(self):
        self.assertEqual(
            self.mod.fill_gap_timestamps([0.0, 4.0, 8.0], 12.0, 10.0, 50), []
        )

    def test_fills_a_long_gap_evenly_including_the_tail_to_duration(self):
        fills = self.mod.fill_gap_timestamps([0.0], 60.0, 10.0, 50)

        self.assertEqual(fills, [10.0, 20.0, 30.0, 40.0, 50.0])

    def test_exact_multiples_of_max_gap_need_no_fill(self):
        self.assertEqual(self.mod.fill_gap_timestamps([0.0, 10.0], 20.0, 10.0, 50), [])

    def test_largest_gap_wins_when_budget_is_short(self):
        fills = self.mod.fill_gap_timestamps([0.0, 12.0, 42.0], 44.0, 10.0, 1)

        self.assertEqual(fills, [27.0])

    def test_partial_budget_spreads_evenly_inside_the_gap(self):
        fills = self.mod.fill_gap_timestamps([0.0], 60.0, 10.0, 2)

        self.assertEqual(fills, [20.0, 40.0])

    def test_zero_budget_fills_nothing(self):
        self.assertEqual(self.mod.fill_gap_timestamps([0.0], 60.0, 10.0, 0), [])


class MetadataParserTests(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def test_parses_metadata_print_timestamps_and_scene_scores(self):
        log = """
        [Parsed_metadata_1 @ 0x123] frame:0 pts:100 pts_time:0.415
        [Parsed_metadata_1 @ 0x123] lavfi.scene_score=0.512000
        [Parsed_metadata_1 @ 0x123] frame:1 pts:6200 pts_time:6.2
        [Parsed_metadata_1 @ 0x123] lavfi.scene_score=0.734
        """

        candidates = self.mod.parse_candidates_from_metadata(log)

        self.assertEqual(
            [(c.timestamp_seconds, c.scene_score) for c in candidates],
            [(0.415, 0.512), (6.2, 0.734)],
        )


class CliTests(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def test_scene_threshold_defaults_to_sensitive_motion_value(self):
        args = self.mod.parse_args(["input.mp4", "-o", "frames"])

        self.assertEqual(args.scene_threshold, 0.005)

    def test_budget_and_coverage_defaults(self):
        args = self.mod.parse_args(["input.mp4", "-o", "frames"])

        self.assertEqual(args.max_frames, 100)
        self.assertEqual(args.max_gap, 10.0)
        self.assertFalse(args.no_dedup)

    def test_rejects_non_positive_max_gap(self):
        with self.assertRaises(SystemExit):
            self.mod.parse_args(["input.mp4", "-o", "frames", "--max-gap", "0"])

    def test_removed_density_flags_are_rejected(self):
        for flag in ("--min-spacing", "--max-per-min", "--min-frames"):
            with self.assertRaises(SystemExit):
                self.mod.parse_args(["input.mp4", "-o", "frames", flag, "3"])


class FilenameTests(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def test_formats_timestamp_as_zero_padded_minutes_seconds_millis(self):
        self.assertEqual(self.mod.frame_filename(65.9876), "frame_01-05-988.jpg")


class MatchTargetsTests(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def candidate(self, timestamp):
        return self.mod.Candidate(timestamp_seconds=timestamp, scene_score=None)

    def test_maps_each_target_to_first_frame_at_or_after_it(self):
        targets = [self.candidate(0.0), self.candidate(1.0), self.candidate(2.0)]

        matched = self.mod.match_targets(targets, [0.0, 1.04, 2.0])

        self.assertEqual(
            [(c.timestamp_seconds, i) for c, i in matched],
            [(0.0, 0), (1.0, 1), (2.0, 2)],
        )

    def test_drops_target_merged_onto_an_already_matched_frame(self):
        targets = [self.candidate(1.0), self.candidate(1.2)]

        matched = self.mod.match_targets(targets, [1.5])

        self.assertEqual([(c.timestamp_seconds, i) for c, i in matched], [(1.0, 0)])

    def test_drops_target_past_the_last_extracted_frame(self):
        targets = [self.candidate(0.0), self.candidate(9.0)]

        matched = self.mod.match_targets(targets, [0.0])

        self.assertEqual([(c.timestamp_seconds, i) for c, i in matched], [(0.0, 0)])


class DedupTests(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def test_drops_thumbnails_close_to_the_last_kept_frame(self):
        flat = bytes([10] * 256)
        near = bytes([11] * 256)
        far = bytes([200] * 256)

        self.assertEqual(self.mod.dedup_drop_indices([flat, near, far, far]), [1, 3])

    def test_compares_against_last_kept_not_previous_frame(self):
        base = bytes([10] * 256)
        drift = bytes([12] * 256)

        self.assertEqual(self.mod.dedup_drop_indices([base, drift, drift]), [1, 2])


class SmokeTests(unittest.TestCase):
    def test_extracts_frames_and_writes_sidecar_from_tiny_mp4(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = pathlib.Path(tmp)
            video_path = tmp_path / "cuts.mp4"
            out_dir = tmp_path / "frames"

            make_video = subprocess.run(
                [
                    "ffmpeg",
                    "-hide_banner",
                    "-loglevel",
                    "error",
                    "-f",
                    "lavfi",
                    "-i",
                    (
                        "color=c=red:s=64x64:d=1[r];"
                        "color=c=blue:s=64x64:d=1[b];"
                        "color=c=green:s=64x64:d=1[g];"
                        "[r][b][g]concat=n=3:v=1:a=0,format=yuv420p"
                    ),
                    "-y",
                    str(video_path),
                ],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=False,
            )
            self.assertEqual(make_video.returncode, 0, make_video.stderr)

            run_cli = subprocess.run(
                [
                    str(SCRIPT),
                    str(video_path),
                    "-o",
                    str(out_dir),
                    "--scene-threshold",
                    "0.1",
                    "--max-dim",
                    "32",
                ],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=False,
            )

            self.assertEqual(run_cli.returncode, 0, run_cli.stderr)
            payload = json.loads((out_dir / "frames.json").read_text())

            meta = payload["meta"]
            self.assertEqual(meta["scene_count"], 2)
            self.assertEqual(meta["fill_count"], 0)
            self.assertLessEqual(meta["subprocess_count"], 5)
            self.assertEqual(meta["deduped_count"], 0)

            frames = payload["frames"]
            self.assertEqual(
                [frame["timestamp_seconds"] for frame in frames], [0.0, 1.0, 2.0]
            )
            self.assertEqual(
                [frame["source"] for frame in frames], ["pinned", "scene", "scene"]
            )
            self.assertIsNone(frames[0]["scene_score"])
            for frame in frames[1:]:
                self.assertIsInstance(frame["scene_score"], float)

            listed = {frame["filename"] for frame in frames}
            on_disk = {path.name for path in out_dir.glob("*.jpg")}
            self.assertEqual(listed, on_disk)
            for frame in frames:
                image_path = out_dir / frame["filename"]
                self.assertTrue(image_path.exists(), frame)
                self.assertGreater(image_path.stat().st_size, 0)


if __name__ == "__main__":
    unittest.main()
