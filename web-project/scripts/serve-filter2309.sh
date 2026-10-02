#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/vendor/emsdk/emsdk_env.sh" >/dev/null
APP="$ROOT/vendor/openFrameworks/apps/myApps/filter2309"
PORT="${1:-${PORT:-8080}}"

if [[ ! "$PORT" =~ ^[0-9]+$ ]]; then
	echo "port must be a number" >&2
	exit 1
fi

listeners() {
	ss -ltnp "sport = :$PORT" 2>/dev/null | sed -n 's/.*pid=\([0-9]\+\).*/\1/p' | sort -u
}

mapfile -t pids < <(listeners)
if ((${#pids[@]})); then
	echo "port $PORT is in use:"
	ps -p "$(IFS=,; echo "${pids[*]}")" -o pid=,user=,args=
	if [[ ! -t 0 ]]; then
		echo "refusing to kill without a terminal" >&2
		exit 1
	fi
	read -r -p "kill? [y/N] " ans
	if [[ "$ans" != [yY] ]]; then
		exit 1
	fi
	kill "${pids[@]}" 2>/dev/null || true
	for _ in 1 2 3 4 5 6 7 8 9 10; do
		sleep 0.2
		mapfile -t pids < <(listeners)
		((${#pids[@]})) || break
	done
	if ((${#pids[@]})); then
		echo "still listening, sending SIGKILL:" >&2
		ps -p "$(IFS=,; echo "${pids[*]}")" -o pid=,args= >&2
		kill -9 "${pids[@]}" 2>/dev/null || true
		sleep 0.2
		mapfile -t pids < <(listeners)
		if ((${#pids[@]})); then
			echo "port $PORT is still in use" >&2
			exit 1
		fi
	fi
fi

cd "$APP"
echo "http://localhost:$PORT/index.html"
exec emrun --no_emrun_detect --no_browser --port "$PORT" bin/em/filter2309
