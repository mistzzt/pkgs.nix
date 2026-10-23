# extract-keyframes

The tool examines every video frame and keeps the first frame. It keeps another frame when a small region changes enough compared with the last retained frame. Gradual changes accumulate until they cross the threshold. Static sections produce no extra images.

Run the tool from the repository root. Use a new or empty output directory:

```bash
nix run .#extract-keyframes -- input.mp4 -o /tmp/keyframes -v
```

The default has no frame limit. To reduce the number of images, increase `--change-threshold` from its default of `0.27`. To retain smaller changes, decrease it. A threshold of zero retains every frame whose analysis image differs from the last retained image.

```bash
nix run .#extract-keyframes -- input.mp4 -o /tmp/keyframes-sensitive --change-threshold 0.18
```

The optional `--max-frames` sets a safety limit. If more frames qualify, the command fails before extraction. It never discards qualifying frames to meet that limit.

The tool compares RGB images resized to 192×108 pixels, divided into 12×12 regions. The score is the largest regional mean absolute difference across pixels and color channels, divided by 255. The tool keeps the frame when its score exceeds the threshold. Small details lost during resizing, or changes below the threshold, can still be missed. Camera motion, lighting changes, and noise can produce extra images.

JPEG output uses `--max-dim 1024` and `--quality 3` by default. Filenames contain the timestamp and decoded frame index. The `frames.json` file records these values, the change score, and the analysis configuration. Timestamps start at the first decoded frame. Extraction uses exact frame indices and preserves variable frame timing.

There is no fixed-interval sampling, global score ranking, or extra duplicate-removal pass. The former scene threshold and gap options are removed.

Run the regression tests through the package build:

```bash
nix build .#extract-keyframes
```
