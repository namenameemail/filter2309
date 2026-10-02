# Audio / cursor root cause (2026-10-02)

## How the patch works (expected)

1. LMB draws into FBO (visual).
2. RMB creates a select rect; Pd metros drive `cursors[n]` across the rect.
3. `pixelColumntToArray(n)` samples a vertical column under the cursor into `filterN` arrays.
4. `noise` abstractions FFT-filter noise by those arrays → `dac~`.

Metros / audio DSP and cursor motion all depend on **Pd audio callbacks**.

## Why browser had draw+select but no cursor/sound

OF nightly `ofxEmscriptenSoundStream` had **html5audio fully commented out** (stub). No ScriptProcessor → no `audioOut` → libpd clock/metros don't advance → silent + frozen cursors.

## Fix

- Restored OF 0.12.0 `ofxEmscriptenSoundStream.cpp`
- Restored `html5audio_context_create()` in SoundPlayer
- Enabled `--js-library library_html5audio.js` in emscripten config
- Fixed `sampleRate.value` → `sampleRate`
- Unlock AudioContext on mousedown/touch/keydown
- `ofSoundStreamStart()` after ofelia.init

Build log: `12-restore-html5audio-build.log`
