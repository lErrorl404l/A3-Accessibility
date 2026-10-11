#!/usr/bin/env bash
# Run the A3ACC in-engine test in the arma3server container.
#
# Builds the addon, assembles the mod set, starts the dedicated server with the
# test mission, captures the log and verifies it. Needs Docker and a CBA_A3
# folder. Set A3ACC_CBA to point at CBA_A3; the default is tests/ingame/mods/@cba_a3.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
LOG="$HERE/run.log"

# Resolve the Arma 3 server install: $ARMA3_SERVER_ROOT, else tests/ingame/server_root,
# else tests/ingame/server.
if [ -z "${ARMA3_SERVER_ROOT:-}" ] && [ -f "$HERE/server_root" ]; then
    ARMA3_SERVER_ROOT="$(head -n1 "$HERE/server_root" | tr -d '[:space:]')"
fi
export ARMA3_SERVER_ROOT="${ARMA3_SERVER_ROOT:-$HERE/server}"
if [ ! -x "$ARMA3_SERVER_ROOT/arma3server_x64" ]; then
    echo "No Arma 3 server at ARMA3_SERVER_ROOT=$ARMA3_SERVER_ROOT" >&2
    echo "Set ARMA3_SERVER_ROOT, or write the path into tests/ingame/server_root." >&2
    exit 1
fi

CBA="${A3ACC_CBA:-$HERE/mods/@cba_a3}"
if [ ! -e "$CBA" ]; then
    echo "CBA_A3 not found at $CBA" >&2
    echo "Set A3ACC_CBA to a CBA_A3 folder, or place one at tests/ingame/mods/@cba_a3." >&2
    exit 1
fi

echo "-> hemtt build"
(cd "$ROOT" && hemtt build >/dev/null)

mkdir -p "$HERE/mods"
if [ ! -e "$HERE/mods/@cba_a3" ]; then
    cp -a "$CBA" "$HERE/mods/@cba_a3"
fi
rm -rf "$HERE/mods/@a3acc"
cp -a "$ROOT/.hemttout/build" "$HERE/mods/@a3acc"

cd "$HERE"
docker compose down >/dev/null 2>&1 || true
echo "-> docker compose up"
docker compose up -d --force-recreate

echo "-> waiting for the DONE marker"
for _ in $(seq 1 90); do
    if docker compose logs 2>/dev/null | grep -q "\[A3ACC-TEST\] DONE"; then
        break
    fi
    sleep 2
done

docker compose logs >"$LOG" 2>&1 || true
docker compose down >/dev/null 2>&1 || true

echo "-> verify"
python3 "$HERE/verify.py" "$LOG"
