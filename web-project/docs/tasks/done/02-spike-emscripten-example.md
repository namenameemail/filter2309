# 02 — Spike: стоковый EmscriptenExample

**Статус:** fail (2026-09-30) → дальше **03**  
**Зависит от:** 00, 01  
**Блокирует:** 04+ (gate)  
**Fallback:** 03  
**Пути:** см. [LAYOUT.md](../../LAYOUT.md)

## Цель

Доказать, что toolchain в `web-project/vendor/` собирает ofxOfelia в браузер.

## Шаги

```bash
cd web-project
source vendor/emsdk/emsdk_env.sh
cd vendor/openFrameworks/addons/ofxOfelia/EmscriptenExample
emmake make
emrun bin/EmscriptenExample.html
```

## Результат

**Fail на compile OF core** (до линковки ofxOfelia).

- Лог: [`logs/spike-02-build.log`](../../logs/spike-02-build.log)
- Кратко: [`logs/spike-02-RESULT.md`](../../logs/spike-02-RESULT.md)

Причина: `updateOF.sh` из ofxOfelia v4.0.0 (2020) подменил  
`config.emscripten.default.mk` на вариант с **`-std=c++14`**.  
OF nightly использует `std::filesystem` → куча ошибок в `ofConstants.h` / `ofFileUtils.h`.

После fail конфиг OF **восстановлен** из master (`config.emscripten.default.mk.OF_ORIGINAL`); бэкап ofelia-конфига:  
`addons/ofxOfelia/scripts/Emscripten/updateOF/config.emscripten.default.mk.ofelia2020.bak`.

## Done when

- ~~сборка без фатальных ошибок~~
- ~~в браузере открывается example~~

## Fail

Если не собирается / не запускается → задача 03. Дальше по плану не идти. **← здесь**
