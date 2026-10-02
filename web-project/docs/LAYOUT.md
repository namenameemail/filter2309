# Layout `web-project/`

Все загрузки, toolchain и артефакты — только здесь. Корень репо (`filter.pd`, `src/`, …) не трогаем как место установки.

```
web-project/
  docs/                 # план и задачи
  downloads/            # сырые архивы (.zip / .tar.gz) до распаковки
  vendor/
    emsdk/              # git clone emsdk + установленный SDK
    openFrameworks/     # OF nightly (распакованный), дальше — OF
  dist/                 # готовая web-сборка для деплоя (.html/.js/.wasm/.data)
```

Пути относительно `web-project/`:

| Что | Куда |
|---|---|
| Архив OF nightly | `downloads/` → распаковать в `vendor/openFrameworks/` |
| emsdk | `vendor/emsdk/` |
| `ofxOfelia_Emscripten.zip` | `downloads/` → `vendor/openFrameworks/addons/ofxOfelia/` |
| Spike / example | `vendor/openFrameworks/addons/ofxOfelia/EmscriptenExample/` |
| App filter2309 | `vendor/openFrameworks/apps/myApps/filter2309/` |
| Выкладка | `dist/` |

Переменная для скриптов: `OF_ROOT=$PWD/vendor/openFrameworks` (из `web-project/`).

`vendor/` и `downloads/` в git не коммитить (тяжёлые); `docs/` и тонкие скрипты — да.

Логи сборок: `docs/logs/`. Выполненные задачи: `docs/tasks/done/`.
