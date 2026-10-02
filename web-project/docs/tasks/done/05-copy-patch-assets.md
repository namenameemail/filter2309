# 05 — Скопировать ассеты патча в bin/data/pd

**Статус:** done (2026-10-02)  
**Зависит от:** 04  
**Блокирует:** 06  
**Пути:** см. [LAYOUT.md](../../LAYOUT.md)

## Цель

Патч и Lua/шейдеры/шрифт в data-каталоге app внутри `web-project/`.

## Результат

`vendor/openFrameworks/apps/myApps/filter2309/bin/data/pd/`:

- `filter.pd`, `noise.pd`
- `src/` (lua, shaders, fonts) — без `._*`
- `saves/` — пустая (только `.gitkeep`)
- `ofelia/abs/` + `ofelia/libs/of/` — для `declare -path` из патча

Пути Lua ок: `canvas:getDir()/src/shaders`, `…/src/fonts/Arial.ttf`, `…/saves/`.

## Done when

- [x] дерево `bin/data/pd/` с рабочим набором без раздутого `saves/`
