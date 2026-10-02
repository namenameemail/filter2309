#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/vendor/emsdk/emsdk_env.sh"
APP="$ROOT/vendor/openFrameworks/apps/myApps/filter2309"
cd "$APP"
emmake make -j"${JOBS:-2}" "$@"
echo "out: $APP/bin/em/filter2309"
