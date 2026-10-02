# 04 — Создать app из EmscriptenExample

**Статус:** done (2026-10-02)  
**Зависит от:** 03  
**Блокирует:** 05, 06  
**Пути:** см. [LAYOUT.md](../../LAYOUT.md)

## Цель

Отдельный OF-проект под filter2309 внутри `web-project/vendor/openFrameworks/`.

## Результат

- App: `vendor/openFrameworks/apps/myApps/filter2309/`
- Сборка: `./scripts/build-filter2309.sh` → `bin/em/filter2309/` (`index.html/js/wasm/data`)
- Лог: [`logs/04-build.log`](../../logs/04-build.log)
- Example в addons не тронут
- Entry patch пока стоковый: `pd/main.pd` (замена — задача 05/06)

## Done when

- [x] `apps/myApps/filter2309` собирается `emmake make`
- [x] example в addons остаётся нетронутым
