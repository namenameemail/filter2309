# Log analysis + sample-off-audio fix

## From user PERF dump

| phase | fps | readAvg | sampleAvg | calls/s | notes |
|-------|-----|---------|-----------|---------|-------|
| select start | 25→15 | ~12ms | ~2ms | ~40 | OK |
| after WRAP1 | ~3 | ~8ms | **130ms** | ~7 | death spiral |

- `readToPixels` stable — not the progressive culprit
- `sample` (`getColor`×256) explodes — SWIG `new ofColor` per call inside Pd metro/audio callback (ScriptProcessor = main thread) → audio overrun → metros stall → worse
- Lua `mem` flat → not a Lua table leak; C++ ofColor churn + audio feedback
- Startup `drawFreq`/`pixelColumntToArray` nil = metros before lua load (noise)

## Fix (14)

1. `readToPixels` once per frame (`ensurePixelsFresh`)
2. Sample in `M.draw` via `refreshActiveFilterCaches` / `fillFilterCache`
3. Reuse `FILTER_CACHE[n]` ofTables (no `table.insert` alloc each tick)
4. `pixelColumntToArray` only returns cache (cheap on audio/Pd path)
