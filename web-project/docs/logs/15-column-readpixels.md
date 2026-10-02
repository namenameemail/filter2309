# Column glReadPixels fix

## Prior log (after draw-cache)

- Passes 1–3: sample~2.5ms, read~16ms, fps~28 — OK
- Pass 4: dt=3167ms stall, then sample stuck ~70ms, fps~9
- Cause: full-FBO `readToPixels` every frame + 256× `getColor` (SWIG `new ofColor`) → GC cliff

## Fix

1. Sample only when `cursors[n]` changes
2. C helper `fboSampleColumnR(fbo,x,y,h,table)`: `glReadPixels` 1×h strip, no ofColor
3. Register helper before opening patch
4. Expect: `setup 12 fboSampleColumnR true`, `readAvg` << 16ms, no sample cliff
