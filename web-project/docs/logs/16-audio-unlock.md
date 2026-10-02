# Audio unlock fix

## Symptom
No sound, cursor stuck at 0 after select. Pd metros need WebAudio callbacks.

## Cause
`html5audio_context_create` unlock handler removed listeners on first call even when `resume()` failed (emrun/autoplay). Later real clicks never unlocked.

## Fix
- Remove listeners only when `context.state === 'running'`
- Also listen `pointerdown` (capture)
- Expose `window.__ofUnlockAudio`; canvas also calls it
