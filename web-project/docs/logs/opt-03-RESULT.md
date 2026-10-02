# OPT-03 — результат

## Изменения

- `library_html5audio.js`: `new AudioContext({ sampleRate: 44100, latencyHint: 'interactive' })`. Раньше контекст брал частоту устройства (48 кГц), Pd считал 44.1 кГц, отсюда `ticksPct≈109`: всё играло на 8.8% быстрее. Также `AUDIO.stream` сохраняет ScriptProcessor, чтобы его можно было отключить.
- `ofxOfelia`: кольцо в фреймах, `RingState { written, read, underruns }` (атомики `uint32`), ёмкость 4096 (степень двойки ради согласованного переполнения), целевое заполнение `ringTargetFrames` (1024 по умолчанию).
- `ofApp.cpp`: `jsStartWorkletOutput` собирает `AudioWorkletProcessor` из Blob и передаёт `HEAPF32.buffer` (SharedArrayBuffer) и указатели на кольцо и `RingState`. Когда модуль загружен, ScriptProcessor отключается. Если AudioWorklet недоступен, остаётся ScriptProcessor.
- Lua: `pdRingTarget(frames)` читает или меняет целевое заполнение на лету. В `PERF out` добавлены `worklet` и `target`.

## Замер (локальный Chrome, без выделений, сборка `opt-03-build.log`)

```
PERF pd ticksPct=100 dsp=160..185ms/s lockWait=2ms/s realtimeX=5.4..6.5
PERF out worklet=1 underruns=0 late=0 ring min/avg/target=192..512/756/1024 base=10.7ms out=237..256ms estLatency=268..287ms
```

Задержка, которую контролирует приложение: кольцо (~17 мс) + квант (3 мс) + `baseLatency` (10.7 мс) ≈ 31 мс. До изменений было ≈ 80 мс. Остальные ~240 мс — `outputLatency` устройства и ОС.
