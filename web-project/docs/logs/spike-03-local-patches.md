# Local patches on ofxOfelia PR #89 (task 03)

1. `libs/ofxPd/.../s_stuff.h` — `#include <stdarg.h>` (emcc -std=c17: `va_list` unknown).
2. `addon_config.mk` emscripten — exclude `libs/ofxPd/.../extra/pd~/%` (не нужен в браузере; первый упавший файл).
3. **Не** запускать `scripts/Emscripten/updateOF.sh` — снова форсит `-std=c++14`.
4. `addon_config.mk` emscripten — `-D_DEFAULT_SOURCE -D_GNU_SOURCE -Wno-implicit-function-declaration -Wno-int-conversion -include alloca.h` (C17 + старый Pd extra).
5. `addon_config.mk` emscripten — `-DHAVE_ENDIAN_H` (иначе Pd `#error unable to detect endianness`).
6. `d_soundfile.h` — не редефайнить `off_t`→`__off64_t` на `__EMSCRIPTEN__`; plus `-U_LARGEFILE64_SOURCE`.
7. `s_inter_gui.c` — не определять stub `dprintf` на `__EMSCRIPTEN__` (конфликт с libc).
8. emscripten: exclude only `pd~/pdsched.c` (не весь `pd~/`), чтобы был `pd_tilde_setup` из `pd~.c`.
9. `EmscriptenExample/config.make` — `PROJECT_EMSCRIPTEN_EMBIND_AOT = 0` (AOT embind падает на wasi fd_read в node tsgen).
10. emscripten: снова exclude `pd~/` целиком + `src/pd_tilde_setup_stub.c` (pd~.c тянет WASI fd_read).
11. `PROJECT_LDFLAGS += -sFORCE_FILESYSTEM=1`.
12. В `config.emscripten.default.mk` **выключить `-s MAIN_MODULE=1`** (оставить `-DEMCC_FORCE_STDLIBS=1`).  
    С MAIN_MODULE wasm импортирует wasi `fd_read`, а JS ждёт его из exports → `LinkError: function import requires a callable`.  
    Бэкап: `config.emscripten.default.mk.bak-mainmodule`.
