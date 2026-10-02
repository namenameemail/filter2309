# 12 — Аудио: DSP после жеста пользователя

**Статус:** todo  
**Зависит от:** 06  
**Блокирует:** —

## Цель

WebAudio стартует после user gesture; Pd DSP слышен.

## Шаги

1. Учесть Autoplay policy (кнопка «Start» / клик по canvas).
2. Включить DSP / resume AudioContext после жеста.
3. Проверить цепочку noise/osc/rfft → dac~.

## Done when

- после клика есть звук в Chrome и Firefox
