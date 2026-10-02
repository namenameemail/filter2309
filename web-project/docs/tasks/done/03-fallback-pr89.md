# 03 — Fallback: PR #89 / свежий ofxOfelia

**Статус:** done (2026-10-02)  
**Зависит от:** 02 = fail  
**Блокирует:** 04  
**Пути:** см. [LAYOUT.md](../../LAYOUT.md)

## Контекст после 02

Сток ofxOfelia_Emscripten v4.0.0 не совместим с OF nightly + emsdk 6.0.10.

## Результат

- Источник: `downloads/ofxOfelia-pr89/` (PR #89) → `vendor/openFrameworks/addons/ofxOfelia/`
- Локальные патчи: [`logs/spike-03-local-patches.md`](../../logs/spike-03-local-patches.md)
- Сборка: `logs/spike-03-build10.log` — **compiling done**
- Артефакты: `.../EmscriptenExample/bin/em/EmscriptenExample/` (`index.html/js/wasm/data`)
- Runtime (headless Chrome): Module ok, canvas 1024×768, `pd 0.54.1`, **без** `fd_read` LinkError

Ключевой фикс runtime: отключить `-s MAIN_MODULE=1` в OF emscripten config.

`updateOF.sh` **не** запускать (снова форсит c++14).

## Done when

- [x] `EmscriptenExample` собирается
- [x] открывается в браузере (wasm стартует, Pd инициализируется)
