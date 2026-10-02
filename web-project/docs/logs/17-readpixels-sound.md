# No sound while cursor moves

DSP/metros OK (cursor advances). Likely filter column all ~0 (white) from raw `glReadPixels` on FBO → `tabreceive~ filter` mutes noise.

## Fix
`fboSampleColumnR` now uses `fbo->readToPixels` + raw byte R channel (same data as old getColor, no ofColor alloc). Logs `filter: sum=...` every 30 samples — sum near 0 = white/silent, sum high = black ink / audible.
