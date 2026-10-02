# OPT-01 — Метрики и baseline

Сборки: `opt-01-build.log`, `opt-01-build2.log`.

## Метрики (лог раз в 5 с, `P` — вкл/выкл)

| Строка | Поле | Смысл |
|---|---|---|
| `PERF pd` | `ticksPct` | тиков Pd от нужного (100 = реальное время) |
| | `dsp` | чистый DSP, мс/с |
| | `lockWait` | Pd-поток ждёт `sys_lock`, мс/с |
| | `realtimeX` | во сколько раз DSP быстрее реального времени |
| `PERF out` | `underruns` | колбэков вывода без полного буфера |
| | `late`, `gapMax` | колбэков с интервалом > 2× буфера (глитч главного потока), макс. интервал |
| | `ring min/avg` | заполнение кольца, фреймы (ёмкость 2048) |
| | `base`, `out` | `AudioContext.baseLatency` / `outputLatency` |
| | `estLatency` | кольцо + 2×буфер ScriptProcessor + base + out |
| `PERF main` | `wait`, `hold`, `holdMax` | главный поток ждёт / держит `sys_lock` |
| | `longTasks`, `longTaskMax` | long tasks > 50 мс (PerformanceObserver) |

`lockWait` замеряется как `sys_lock()+sys_unlock()` перед тиком — приближённо.

## Предварительно (встроенный браузер Cursor, idle)

- `realtimeX` ≈ 5.5 → DSP ≈ 18% ядра;
- `outputLatency` ≈ 240 мс — браузер/аудиосистема добавляет больше, чем все наши буферы; `estLatency` ≈ 320 мс;
- кольцо в среднем полное (≈ 1900–2030 из 2048) → +46 мс;
- `holdMax` до 57 мс, long task до 333 мс → главный поток держит замок Pd дольше ёмкости кольца.

## Сценарии (Chrome, DevTools закрыт, 60 с каждый)

| Сценарий | realtimeX | lockWait | underruns | late/gapMax | out latency | estLatency | holdMax | longTasks | fps / frame max |
|---|---|---|---|---|---|---|---|---|---|
| idle | | | | | | | | | |
| 1 выделение | | | | | | | | | |
| 6 выделений | | | | | | | | | |
| 6 + спектр | | | | | | | | | |
| рисование кистью | | | | | | | | | |

## Решения

- целевая машина/браузер: —
- целевой fps: —
- нативный референс: —
- go/no-go opt-02: —
