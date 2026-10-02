# 00 — Установить openFrameworks + Emscripten

**Статус:** done (2026-09-30)  
**Зависит от:** —  
**Блокирует:** 01, 02  
**Пути:** см. [LAYOUT.md](../../LAYOUT.md)

Результат:
- OF: `downloads/of_v20260930_linux64_gcc6_release.tar.gz` → `vendor/openFrameworks/`
- emsdk: `vendor/emsdk/` → SDK / emcc **6.0.10**

## Цель

Рабочий OF nightly и `emcc` внутри `web-project/`.

## Шаги

Из `web-project/`:

1. Создать `downloads/`, `vendor/`, `dist/` если нет.
2. Скачать [OF nightly](https://openframeworks.cc/download/) (Linux 64) в `downloads/`.
3. Распаковать в `vendor/openFrameworks/` (чтобы был `vendor/openFrameworks/libs/`).
4. Клонировать emsdk в `vendor/emsdk/`:
   ```bash
   git clone https://github.com/emscripten-core/emsdk.git vendor/emsdk
   cd vendor/emsdk
   ./emsdk install latest
   ./emsdk activate latest
   source ./emsdk_env.sh
   ```
5. Проверить: `emcc --version`.

## Done when

- `emcc --version` печатает версию (после `source vendor/emsdk/emsdk_env.sh`)
- есть `vendor/openFrameworks/libs/`
- архив OF лежит в `downloads/`
