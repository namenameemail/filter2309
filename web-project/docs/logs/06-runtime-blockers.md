# 06 — Runtime blockers (filter.pd first browser run)

Date: 2026-10-02  
Build: `docs/logs/06-build.log`  
Artifacts: `…/bin/em/filter2309/` (`index.data` ~495K)

## OK

- WASM starts, `Module.aborted === false`
- Canvas **1280×960** (из патча)
- Pd 0.54.1 + ofelia init
- Lua доходит до setup (`new1 1280 960`)

## Blockers → downstream tasks

| # | Симптом | Задача |
|---|---|---|
| 1 | Шейдеры: `#version 120`, `sampler2DRect`, `ftransform`, no precision | **07** |
| 2 | Ранние `drawFreq` / `pixelColumntToArray` = nil до load `main.lua` (метро/порядок) | патч/порядок load; связано с 06 residual |
| 3 | `ofPixels: image type not supported` (webcam/grab?) | **08** |
| 4 | Save/PNG на MEMFS бессмысленен | **09** |
| 5 | `ReferenceError: e is not defined` (JS) | **10** / OF input glue |
| 6 | Autoplay / DSP после жеста не проверено явно | **12** |
| 7 | `hanning`/`arr*`: multiply defined (noise×6) | шум, не блокер |
| 8 | MidiIn/OutDummy | ожидаемо в браузере |
| 9 | один 404 resource | уточнить при полировке |

## Notes

Шейдерные ошибки повторяются для BW/Freq/FMB — без **07** кисти camera/fractal/spectre не работают.
