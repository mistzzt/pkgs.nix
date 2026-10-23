import importlib.machinery
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

import numpy as np


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "extract-keyframes"
loader = importlib.machinery.SourceFileLoader("extract_keyframes_cli", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = mod
loader.exec_module(mod)


def image(value=0):
    return np.full((mod.ANALYSIS_HEIGHT, mod.ANALYSIS_WIDTH, 3), value, dtype=np.uint8)


class ChangeTests(unittest.TestCase):
    def kept_indices(self, images, threshold=0.03):
        selector = mod.ChangeSelector(threshold)
        return [i for i, frame in enumerate(images) if selector.consider(frame)[0]]

    def test_static_frames_are_not_repeated_even_at_zero_threshold(self):
        self.assertEqual(self.kept_indices([image(30)] * 50, 0), [0])

    def test_gradual_change_accumulates_against_last_kept_frame(self):
        self.assertEqual(self.kept_indices([image(i) for i in range(0, 22, 3)]), [0, 3, 6])

    def test_local_change_is_not_diluted_by_the_rest_of_the_image(self):
        changed = image()
        changed[24:36, 48:60] = 24
        self.assertLess(changed.mean() / 255, 0.03)
        self.assertEqual(self.kept_indices([image(), changed]), [0, 1])

    def test_single_frame_change_and_return_are_both_retained(self):
        self.assertEqual(self.kept_indices([image(), image(80), image(), image()]), [0, 1, 2])

    def test_color_change_with_similar_luminance_is_retained(self):
        red, green = image(), image()
        red[:, :, 0] = 255
        green[:, :, 1] = 130
        self.assertEqual(self.kept_indices([red, green]), [0, 1])


class CliTests(unittest.TestCase):
    def test_default_has_no_frame_cap(self):
        args = mod.parse_args(["input.mp4", "-o", "frames"])
        self.assertIsNone(args.max_frames)
        self.assertEqual(args.change_threshold, 0.27)

    def test_large_explicit_limit_is_supported(self):
        args = mod.parse_args(["input.mp4", "-o", "frames", "--max-frames", "10000"])
        self.assertEqual(args.max_frames, 10000)

    def test_nonfinite_and_out_of_range_thresholds_are_rejected(self):
        for value in ["nan", "inf", "-0.1", "1.1"]:
            with self.subTest(value=value), self.assertRaises(SystemExit):
                mod.parse_args(["input.mp4", "-o", "frames", f"--change-threshold={value}"])

    def test_filename_keeps_submillisecond_frames_distinct(self):
        self.assertNotEqual(
            mod.frame_filename(mod.Frame(0, 0, None)),
            mod.frame_filename(mod.Frame(1, 0.0001, 0.1)),
        )


class VideoTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.video = self.root / "input.mkv"
        self.output = self.root / "frames"

    def make_video(self, frames, rate=30, vf=None):
        height, width, _ = frames[0].shape
        args = [
            "ffmpeg", "-hide_banner", "-loglevel", "error", "-f", "rawvideo",
            "-pix_fmt", "rgb24", "-s", f"{width}x{height}", "-framerate", str(rate),
            "-i", "-",
        ]
        if vf:
            args.extend(["-vf", vf])
        args.extend([
            "-fps_mode", "passthrough", "-c:v", "libx264rgb", "-crf", "0",
            "-preset", "ultrafast", str(self.video),
        ])
        result = subprocess.run(args, input=b"".join(f.tobytes() for f in frames), capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr.decode())

    def run_cli(self, *extra, success=True):
        result = subprocess.run(
            [str(SCRIPT), str(self.video), "-o", str(self.output), *extra],
            capture_output=True, text=True,
        )
        if not success:
            self.assertNotEqual(result.returncode, 0)
            return result
        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads((self.output / "frames.json").read_text())
        self.assertEqual(
            {f["filename"] for f in payload["frames"]},
            {p.name for p in self.output.glob("*.jpg")},
        )
        return payload

    def test_long_static_video_keeps_only_first_frame(self):
        self.make_video([np.full((24, 32, 3), 50, dtype=np.uint8)] * 120, rate=2)
        payload = self.run_cli()
        self.assertEqual(payload["meta"]["analyzed_count"], 120)
        self.assertEqual([f["frame_index"] for f in payload["frames"]], [0])

    def test_brief_small_color_change_survives_downscaling(self):
        base = np.zeros((720, 1280, 3), dtype=np.uint8)
        base[:, :, 0] = 255
        changed = base.copy()
        changed[240:320, 480:560] = [0, 130, 0]
        self.make_video([base, base, changed, base, base])
        payload = self.run_cli()
        self.assertEqual([f["frame_index"] for f in payload["frames"]], [0, 2, 3])

    def test_variable_timestamps_and_exact_selected_image(self):
        frames = [np.full((24, 32, 3), value, dtype=np.uint8) for value in [0, 100, 200]]
        self.make_video(frames, rate=10, vf="setpts='if(eq(N,0),0,if(eq(N,1),1,10))'")
        payload = self.run_cli()
        self.assertEqual([f["timestamp_seconds"] for f in payload["frames"]], [0, 0.1, 1])
        for frame, expected in zip(payload["frames"], [0, 100, 200]):
            decoded = subprocess.run(
                ["ffmpeg", "-v", "error", "-i", str(self.output / frame["filename"]),
                 "-f", "rawvideo", "-pix_fmt", "rgb24", "-"], capture_output=True,
            )
            self.assertEqual(decoded.returncode, 0, decoded.stderr.decode())
            self.assertAlmostEqual(np.frombuffer(decoded.stdout, dtype=np.uint8).mean(), expected, delta=2)

    def test_more_than_old_limit_extracts_without_losses(self):
        black = np.zeros((8, 8, 3), dtype=np.uint8)
        white = np.full_like(black, 255)
        self.make_video([black, white] * 1001)
        payload = self.run_cli()
        self.assertEqual(payload["meta"]["analyzed_count"], 2002)
        self.assertEqual([f["frame_index"] for f in payload["frames"]], list(range(2002)))

    def test_explicit_limit_fails_without_partial_output(self):
        self.make_video([image(), image(100), image(200)])
        result = self.run_cli("--max-frames", "2", success=False)
        self.assertIn("more than 2 frames qualify", result.stderr)
        self.assertFalse(self.output.exists())

    def test_missing_input_reports_ffmpeg_failure(self):
        result = self.run_cli(success=False)
        self.assertIn("No such file", result.stderr)
        self.assertFalse(self.output.exists())

    def test_existing_output_is_not_mixed_with_new_run(self):
        self.output.mkdir()
        old = self.output / "frame_old.jpg"
        old.write_bytes(b"keep")
        result = self.run_cli(success=False)
        self.assertIn("output directory must be empty", result.stderr)
        self.assertEqual(old.read_bytes(), b"keep")


if __name__ == "__main__":
    unittest.main()
