# 06 — Entry-patch + первая сборка filter2309

**Статус:** done (2026-10-02)  
**Зависит от:** 05  
**Блокирует:** 07–12  
**Пути:** см. [LAYOUT.md](../../LAYOUT.md)

## Результат

- Entry: `ofApp.cpp` → `pd/filter.pd`
- Сборка: [`logs/06-build.log`](../../logs/06-build.log) — ok
- Runtime: WASM + Pd + Lua, canvas 1280×960
- Блокеры: [`logs/06-runtime-blockers.md`](../../logs/06-runtime-blockers.md)

## Done when

- [x] WASM стартует
- [x] патч/окно Ofelia инициализируется
- [x] список блокеров записан
