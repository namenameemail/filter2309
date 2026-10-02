# 14 — Деплой

**Статус:** todo  
**Зависит от:** 13  
**Блокирует:** 15  
**Пути:** см. [LAYOUT.md](../LAYOUT.md)

## Цель

Статическая выкладка в `web-project/dist/` с правильными MIME и HTTPS (для mic).

## Шаги

1. Скопировать артефакты сборки app (`.html` + `.js` + `.wasm` + `.data`) в `web-project/dist/`.
2. Раздавать из `dist/` (static server / hosting).
3. HTTPS (или tunnel), если камера/mic не с localhost.
4. Проверить MIME для wasm/data.

## Done when

- URL открывается с другой машины/профиля браузера
- камера запрашивается только на secure context
- содержимое деплоя лежит в `dist/`
