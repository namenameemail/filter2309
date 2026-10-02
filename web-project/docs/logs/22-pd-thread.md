# 22 — Pd в отдельном pthread

Сборки: `22-pd-thread-build.log`, `22-pd-thread-build2.log`, `22-pd-thread-build3.log`.

## Что сделано

- `ofxOfelia`: `startPdThread(frames)` — Pd считает тиками по 64 фрейма в `std::thread`, пишет в SPSC-кольцо (`blockSize*ticksPerBuffer*4` = 2048 фреймов); `audioOut` (ScriptProcessor, main) только копирует, при нехватке — тишина и `audioUnderruns++`.
- `PD_SYS_LOCK` считает ожидающих (`ofxOfelia::mainLockWaiters`), Pd-поток уступает замок главному.
- `drawFreq()` из Pd только инкрементирует `freqPendingColumns`; рисует `drawPendingFreq()` в `M.draw`.
- `M.setup` однократный: повторный вызов приходил из `ofClock` на первом тике Pd — теперь это Pd-поток, `shader:load` → `detachShader` из воркера падал.
- Lua GC остановлен (`collectgarbage("stop")`), шаг в `M.draw` — финализаторы GL-объектов не должны срабатывать в Pd-потоке.
- PERF: `PERF pdThread ticks busy underruns` (`busy` включает ожидание `sys_lock`).

## Замеры (Chrome, 1 выделение)

| Метрика | До (Pd в main) | После |
|---|---|---|
| fps | ~30, провалы | 29.5 стабильно в норме |
| frame max | 110–170 мс | 50–70 мс в норме, пики до 330 мс |
| draw avg | 13–15 мс (2 выдел.) | 9–11 мс |
| звук в main | 380–540 мс/с | ≈ 0 |
| underruns | — | 0–3/с норма, 30–66/с в пиках |

## Проблемы → блок «Оптимизация»

- звук отстаёт от курсора (~80–110 мс по цепочке буферов);
- обрывы: draw держит `sys_lock` весь кадр; вывод через ScriptProcessor в main;
- пики совпадают с потоком WebGL-предупреждений PBO.

См. [tasks/opt-00-overview.md](../tasks/opt-00-overview.md).
