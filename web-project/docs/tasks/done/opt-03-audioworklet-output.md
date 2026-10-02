# OPT-03 — Вывод звука через AudioWorklet

**Статус:** done  
**Зависит от:** opt-02  
**Блокирует:** opt-05

## Цель

Звук не зависит от главного потока: Pd pthread пишет в кольцо в SharedArrayBuffer, `AudioWorkletProcessor` читает по 128 фреймов.

## Шаги

1. Отдельный SAB-кольцо (не `HEAPF32`: при `ALLOW_MEMORY_GROWTH` буфер кучи меняется) + атомарные индексы read/write; C++ пишет через указатель на общий буфер или фиксированную область кучи без роста.
2. JS `AudioWorkletProcessor` (чистый JS, без wasm в ворклете), загрузка через `audioWorklet.addModule`, передача SAB через `port`.
3. Заменить ScriptProcessor (html5audio) для этого приложения; разблокировка `AudioContext` по жесту — как сейчас.
4. Pd-поток просыпается по уровню кольца (`Atomics.wait`/sleep), целевой уровень 512–1024 фреймов.
5. Счётчики в ворклете: underruns, текущий уровень, `playedFrames` (для opt-05).

## Риски

- интеграция с ofxEmscripten soundstream; при сложностях — свой минимальный JS-модуль вместо `ofSoundStream`;
- COOP/COEP обязательны (уже нужны для pthreads).

## Done when

- ScriptProcessor не используется;
- при искусственном фризе главного потока на 200 мс звук не рвётся (кольцо хватает);
- underruns = 0 в сценарии «6 выделений» при нормальной работе.
