# 09 — Save: download вместо ofSaveImage на диск

**Статус:** todo  
**Зависит от:** 06  
**Блокирует:** —

## Цель

Автосейв/`saveFBO2` не пишет в бесполезный MEMFS; пользователь может получить PNG.

## Шаги

1. Найти `ofSaveImage` / `saveFBO2` в `src/main.lua`.
2. Либо отключить автосейв, либо заменить на browser download (blob / emscripten FS sync + JS).
3. Не включать массовый `saves/` в data-пакет.

## Done when

- нет тихой «записи» в никуда
- ручной экспорт PNG работает или автосейв явно выключен
