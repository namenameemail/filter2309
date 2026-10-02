# 18 — narrow column read

`fboSampleColumnR` (`apps/myApps/filter2309/src/ofApp.cpp`) reads a 1×span strip with `glReadPixels(x, minY, 1, spanH)` instead of a full `readToPixels`.

- On GLES, `ofFbo::readToPixels` is `bind(); glReadPixels(0,0,w,h); unbind();` without a Y flip, so pixel row `y` is GL row `y`. The earlier narrow version flipped `fboH - y - h` and read the mirrored, white area, which gave silence.
- Rows are computed with the original Lua formula `sy + t*(h-1)`, which keeps negative `h` (selection dragged upward). minY and maxY bound the strip.
- `GL_PACK_ALIGNMENT = 1`, because the row width is 1 pixel.
- The debug `filter: sum=` log was removed.

Build log: `18-narrow-column-build.log`.

## Result

The narrow read cut `readAvg` from about 15–18ms to 6–10ms, and the sound stayed correct. The remaining time is the synchronous GPU stall inside `glReadPixels`, which barely depends on the byte count.

## 19 — deferred read through a pixel pack buffer

`ColumnRead` in `ofApp.cpp` keeps one `GL_PIXEL_PACK_BUFFER`. Each call stages `glReadPixels(..., nullptr)` into it and sets a fence, then returns the strip staged on the previous call once `glClientWaitSync` with a zero timeout reports it ready. The filter therefore trails the cursor by one step, and the CPU no longer waits for the GPU. If the previous read is not ready yet, the call returns the table unchanged.

Emscripten's `glMapBufferRange` rejects `GL_MAP_READ_BIT` ("does not support MAP_READ") and returns null, which gave silence. The readback uses `glGetBufferSubData`, which maps to WebGL2 `getBufferSubData`.

Two more bugs in the first PBO version:

- Re-staging while a read was still pending overwrote the buffer and leaked the fence. Chrome reported "READ-usage buffer was written ... discarded the shadow copy", followed by `glFenceSync` errors. Without the shadow copy, `getBufferSubData` makes a synchronous GPU round trip of about 3–4ms.
- A single `ColumnRead` was shared by all selects, so with two or more selects each one received a neighbour's column.

Fix: `ColumnRead` is now kept per filter table (`lua_topointer(FILTER_CACHE[n])`). While the fence is unsignalled the call returns the table unchanged and stages nothing.

Build log: `19-pbo-column-build.log`.
