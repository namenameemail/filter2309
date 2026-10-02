# 07 — Порт шейдеров под WebGL / GLSL ES

**Статус:** done (2026-10-02)  
**Зависит от:** 06  
**Блокирует:** осмысленный camera/fractal/spectre  
**Пути:** см. [LAYOUT.md](../../LAYOUT.md)

## Результат

- Добавлены `src/shaders/shadersES2/` (`shaderBW`, `shaderFreq`, `shaderFMB`) — `#version 100`, `sampler2D`, MVP vert
- `main.lua`: на Emscripten / programmable → ES2 + `ofDisableArbTex()`; десктоп GL2 → старые шейдеры
- `setUniformTexture("tex0", …)` для camera brush
- Сборка: [`logs/07-build.log`](../../logs/07-build.log)
- Runtime: [`logs/07-RESULT.md`](../../logs/07-RESULT.md) — **0** ошибок ofShader compile/link

## Done when

- [x] шейдеры без GL-ошибок в консоли (compile/link)
