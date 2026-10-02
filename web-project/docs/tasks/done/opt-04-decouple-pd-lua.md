# OPT-04 — Развязать Pd и Lua (draw без `sys_lock`)

**Статус:** done  
**Зависит от:** opt-02  
**Блокирует:** opt-05

## Цель

Pd-поток не вызывает Lua и не ждёт главный поток; главный поток не берёт `sys_lock` на время кадра.

## Текущие точки связи

| Направление | Где | Что |
|---|---|---|
| Pd → Lua | `ofelia f` в `filter.pd` | `cursors[n] = a` (metro 50), `pixelColumntToArray(n)` (metro 100), `drawFreq()` (metro 50) |
| Lua → Pd | `workspace.lua` | `sends[...]:sendFloat(...)` из ввода/draw |
| Lua читает Pd | `drawPendingFreq` | `ofArray('freq')` |
| Слушатели | `ofxOfeliaEvents.h` | `PD_SYS_LOCK` вокруг каждого вызова Lua |

## Шаги

1. **Pd → main:** курсоры и сигнал «новый столбец спектра» — через `[s]` + очередь сообщений libpd (queued mode) или свой SPSC; главный поток разбирает в `update`.
2. **Фильтры main → Pd:** вместо `pixelColumntToArray` (Pd тянет из Lua) главный поток пишет столбец в очередь/двойной буфер; Pd-поток копирует в `filterN` в начале тика.
3. **sendFloat:** очередь (receiver, value), применяется Pd-потоком перед тиком.
4. **Спектр:** Pd-поток копирует `freq` в двойной буфер; draw читает без замка.
5. Убрать `PD_SYS_LOCK` для draw/update/input на web; Lua защищён тем, что вызывается только из главного потока (проверка-ассерт).
6. Патч: заменить соответствующие `ofelia f` на `[s]`/`[r]`, не меняя звучание.

## Реализация (без изменения `filter.pd`)

- `ofxOfeliaThreading.{h,cpp}`: `luaMutex` (recursive), `onPdThread`, очередь отложенных сообщений.
- Слушатели (`PD_SYS_LOCK`) берут только `luaMutex`, не `sys_lock`.
- Входы `ofelia f/d` (`bang/float/symbol/list/anything`) на Pd-потоке: `try_lock`; занято → сообщение в очередь, повтор в начале следующего тика (≤ 1.45 мс + длительность кадра). Порядок сохраняется. `pdClock` → `clock_delay(0)`.
- Вызовы Lua → Pd (`pdSend`, `pdArray`, `pdValue`) на главном потоке: `ofxOfeliaPdAccess` — короткий `sys_lock` (до старта Pd-потока не берётся, чтобы не повиснуть внутри `openPatch`).
- `drawPendingFreq`: `ofArray('freq'):get(0)` — одно чтение массива вместо 256.
- Лог: `opt-04-build.log`. Первый замер: `lockWait` 57–156 → 3 мс/с, `pdHold` ≈ 0.

## Done when

- в Pd-потоке ноль вызовов Lua (счётчик/ассерт);
- `lockWaitMs` Pd-потока ≈ 0 при любом fps;
- поведение фильтров/курсоров/спектра как до изменений.
