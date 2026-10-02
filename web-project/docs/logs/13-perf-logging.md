# PERF logging (task-style note)

## What
Timed `pixelColumntToArray` + draw. Logs every 1s to console (emrun / browser).

## Ofelia note
`read -c` turns newlines into `;` — no multiline `{...}` / `fn(` arg lists in Lua loaded this way.

## Lines
- `PERF t=... fps=... drawAvg=... mem=... selects=...` — frame + Lua heap
- `PERF colN calls=... readAvg=... sampleAvg=... dtAvg=... passes=...` — per select
  - `read*` = `fbo2:readToPixels` (GPU sync, main suspect)
  - `sample*` = 256× `getColor`
  - `dt*` = gap between column reads (metro target ~100ms; growth = backlog)
- `PERF WRAP colN pass=...` — each cursor lap

## Toggle
`P` / `p` — on/off

## Expect if slowdown is readback
`readAvg` / `dtMax` climb each pass; `mem` may climb if leak.
