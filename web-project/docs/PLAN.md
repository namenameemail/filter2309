# filter2309 → браузер (ofxOfelia + Emscripten)

Декомпозиция в задачи: [tasks/](tasks/README.md).  
Куда класть файлы: [LAYOUT.md](LAYOUT.md) — всё под `web-project/` (`downloads/`, `vendor/`, `dist/`).  
Выполненные задачи → [tasks/done/](tasks/done/). Логи → [logs/](logs/).

## Вердикт

На текущей Ubuntu (24.04, x86_64) собрать можно. Официальный путь: **ofxOfelia + openFrameworks nightly + Emscripten**.

Это не «закинул патч и собрал»: релиз ofxOfelia 2020-го года, плюс у патча есть браузерные ограничения (шейдеры, webcam, save, ПКМ/колёсико).

## Окружение (снимок)

| | |
|---|---|
| Ubuntu 24.04, 8 CPU, ~123 GB свободно | ок |
| g++ / make / cmake / git / python3 / node | ок |
| ~15 GB RAM + 18 GB swap | сборка тяжёлая, но пройдёт |
| Emscripten (`emcc`) | нет — поставить |
| openFrameworks / ofxOfelia | нет — скачать |
| Pure Data на хосте | для web-сборки не нужен (ofxPd внутри ofxOfelia) |

Патч: vanilla Pd + Ofelia (`ofWindow`, Lua, шейдеры, FBO, webcam). Сторонних externals (cyclone/else) нет.

## Риски

1. **Стек устарел.** `ofxOfelia_Emscripten.zip` — v4.0.0 (2020). README требует OF nightly. Если стоковый example не соберётся — взять [PR #89](https://github.com/cuinjune/Ofelia/pull/89) (апр. 2024, правки под современный Emscripten).
2. **Шейдеры не WebGL-ready.** `#version 120`, `sampler2DRect` / `texture2DRect` / `ftransform()` → нужен порт на GLSL ES / `sampler2D`.
3. **Webcam** (`ofVideoGrabber`) — getUserMedia: только localhost/HTTPS + разрешение пользователя.
4. **`ofSaveImage` → `saves/`** в браузере бессмысленно (MEMFS) → download или отключить автосейв.
5. **ПКМ / MMB / scroll** — ядро UX; в браузере context menu и иное поведение колёсика. Нужны `preventDefault` и, при необходимости, альтернативы.

Остальное (`noise~`, `osc~`, `rfft~`, `dac~`, FBO 1280×960, `Arial.ttf`) обычно поднимается после успешного example.

## План работ

### 0. Spike (решает «можно ли вообще»)

Всё внутри `web-project/` (см. LAYOUT).

1. OF nightly → `downloads/` → `vendor/openFrameworks/`.
2. emsdk → `vendor/emsdk/` (`install/activate latest`, `source emsdk_env.sh`).
3. `ofxOfelia_Emscripten.zip` → `downloads/` → `vendor/openFrameworks/addons/ofxOfelia`, `scripts/Emscripten/updateOF.sh`.
4. Собрать сток:
   ```bash
   cd web-project/vendor/openFrameworks/addons/ofxOfelia/EmscriptenExample
   emmake make
   emrun bin/EmscriptenExample.html
   ```
5. Если fail — повторить с веткой/PR #89 (тоже под `vendor/`).

Без зелёного example дальше не идти.

### 1. Проект под патч

1. Скопировать example → `vendor/openFrameworks/apps/myApps/filter2309/`.
2. В `bin/data/pd/` положить `filter.pd`, `noise.pd`, `src/` из корня репо. `saves/` не тащить.
3. Прописать entry-patch; собрать; зафиксировать runtime-ошибки.
4. Выкладку складывать в `web-project/dist/`.

### 2. Порт под браузер (обязательный diff патча)

1. Шейдеры → GLSL ES / WebGL2.
2. Webcam: graceful fallback при отказе/отсутствии камеры.
3. Save: «скачать PNG» вместо записи на диск (или отключить `saveFBO2`).
4. Input: заглушить context menu; проверить MMB/scroll; при необходимости дублировать жесты клавишами.
5. Размер окна / HiDPI / fullscreen под canvas в HTML.

### 3. Аудио и UX

1. Старт DSP после жеста пользователя (Autoplay policy).
2. Проверить latency/CPU на спектре и 6 фильтрах.
3. Сжать ассеты; флаги `-O2`/`-O3`; правильный MIME при деплое (`.wasm`, `.data`).

### 4. Деплой

1. Артефакты: `.html` + `.js` + `.wasm` + `.data`.
2. Static server + HTTPS для mic.
3. Smoke: Chrome + Firefox, с камерой и без.

## Оценка

| Этап | Время |
|---|---|
| Spike example | 0.5–1 день (с PR #89 — до 2) |
| Вставка патча + пути | ~0.5 дня |
| Шейдеры + input + save + webcam | 2–4 дня |
| Полировка / деплой | 0.5–1 день |
| **Итого** | **~1–1.5 недели** до рабочей web-версии |

## Рекомендация

Сначала только spike `EmscriptenExample`. Зелёный — идём в порт `filter2309`. Красный — сразу PR #89, не тратить время на шейдеры в мёртвом toolchain.

## Ссылки

- Ofelia: https://github.com/cuinjune/Ofelia
- ofxOfelia releases: https://github.com/cuinjune/ofxOfelia/releases/latest
- OF Emscripten setup: https://openframeworks.cc/setup/emscripten/
- PR #89 (Emscripten update 2024): https://github.com/cuinjune/Ofelia/pull/89
