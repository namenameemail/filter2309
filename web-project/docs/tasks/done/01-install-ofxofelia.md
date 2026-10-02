# 01 — Поставить ofxOfelia (Emscripten)

**Статус:** done (2026-09-30)  
**Зависит от:** 00  
**Блокирует:** 02  
**Пути:** см. [LAYOUT.md](../../LAYOUT.md)

Результат:
- `downloads/ofxOfelia_Emscripten.zip` (v4.0.0, 1.6M)
- `vendor/openFrameworks/addons/ofxOfelia/` (+ EmscriptenExample)
- `updateOF.sh` ок → обновлён `config.emscripten.default.mk`

## Цель

ofxOfelia в `vendor/openFrameworks/addons/ofxOfelia`, OF обновлён скриптом addon’а.

## Шаги

Из `web-project/`:

1. Скачать [ofxOfelia_Emscripten.zip](https://github.com/cuinjune/ofxOfelia/releases/latest) в `downloads/`.
2. Распаковать → переименовать в `ofxOfelia` →  
   `vendor/openFrameworks/addons/ofxOfelia/`.
3. ```bash
   cd vendor/openFrameworks/addons/ofxOfelia/scripts/Emscripten
   sudo ./updateOF.sh
   ```

## Done when

- есть `vendor/openFrameworks/addons/ofxOfelia/EmscriptenExample`
- `updateOF.sh` завершился без ошибки
- zip остаётся в `downloads/`
