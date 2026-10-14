#!/usr/bin/env bash
# Run the A3 Accessibility client probe end to end, with no debug console and no
# pasting.
#
# The client is the only place a rendered result can be seen. Until now a person
# launched the game, pasted two probes into the debug console and read the report
# back. This script closes that gap. It:
#
#   1. refuses to start while an Arma 3 client is already running;
#   2. builds the addon and the dev-only probe mod under tests/probe_mod;
#   3. starts a local dedicated server (the tests/ingame Docker image) with a
#      mission that gives a player;
#   4. launches the Arma 3 client under Proton with CBA and the probe mod loaded;
#   5. follows the client report until the probe's DONE marker, with a timeout;
#   6. captures one screenshot per probe step, so each mode can be judged from an
#      image and not from a person watching;
#   7. quits the client, runs tests/check_client_rpt.py on the report and prints
#      one block per check.
#
# It is safe to run twice: the second run finds no client and starts cleanly.
#
# THE RUN IS ISOLATED. The client receives -profiles= pointed at a scratch
# directory inside this runner's own tree, tests/probe_mod/run/profiles. The
# engine puts the profile, its Arma3.cfg, its logFiles (the .rpt reports) and its
# data caches there, so the run writes nothing into the owner's Documents, into
# the Proton prefix or into the mods another project keeps in the game folder.
# The Steam Linux Runtime keeps its own scratch overlay under its install tree,
# which the check reports as a warning. It is not redirected into this repository,
# because pressure-vessel copies the runtime when the two are on different
# filesystems, which measured 581 MB per run.
# The script snapshots every tree outside the repository before and after the run,
# prints one line per tree and fails the run when a tree it owns changes.
#
# THE REPORTS ARE ARCHIVED. The engine rotates its reports by count, so a report
# left in the engine's own folder is deleted by a later run, and its reading is
# evidence that cannot be recreated. Every report the run produces is copied into
# docs/evidence/client-probe/<YYYYMMDDTHHMMSSZ>/ when the run ends. The stamp is
# the UTC time the run ended. Each report keeps the file name the engine gave it,
# so arma3_x64_2026-10-14_16-24-56.rpt stays identifiable. The probe's own
# [A3ACC-PROBE] lines are written to readings.txt in the same folder, and the
# outside-repo check is written to isolation.txt next to them.
#
# Environment:
#   A3ACC_CBA          a CBA_A3 folder (default tests/ingame/mods/@cba_a3)
#   A3ACC_ARMA3        the Arma 3 client folder
#   A3ACC_SERVER_ROOT  a Linux Arma 3 server install (default /ext/Development/a3pm-server)
#   A3ACC_PROTON       the proton executable
#   A3ACC_STEAM_ROOT   the Steam root (default ~/.local/share/Steam)
#   A3ACC_COMPAT_DATA  the client's Proton prefix (default the Arma 3 app id)
#   A3ACC_GAME_PORT    the server game port (default 2312)
#   A3ACC_TIMEOUT      seconds to wait for the DONE marker (default 420)
#   A3ACC_SHOT         the screenshot tool: spectacle or import
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
RUN="$HERE/probe_mod/run"
SHOTS="$RUN/shots"
PROFILES="$RUN/profiles"
EVIDENCE_ROOT="$ROOT/docs/evidence/client-probe"

ARMA3="${A3ACC_ARMA3:-/ext/SteamLibrary/steamapps/common/Arma 3}"
SERVER_ROOT="${A3ACC_SERVER_ROOT:-/ext/Development/a3pm-server}"
CBA="${A3ACC_CBA:-$HERE/ingame/mods/@cba_a3}"
STEAM_ROOT="${A3ACC_STEAM_ROOT:-/home/matt/.local/share/Steam}"
COMPAT_DATA="${A3ACC_COMPAT_DATA:-/ext/SteamLibrary/steamapps/compatdata/107410}"
PROTON="${A3ACC_PROTON:-$STEAM_ROOT/compatibilitytools.d/Proton-CachyOS Latest/proton}"
RUNTIME="${A3ACC_RUNTIME:-$STEAM_ROOT/steamapps/common/SteamLinuxRuntime_4/_v2-entry-point}"
# The runtime keeps its own scratch overlay in var/ next to the entry point. It
# is watched below as a warning, because the runtime owns it. Moving it into this
# repository was measured and rejected: pressure-vessel cannot hard link across
# filesystems, so it copies 581 MB of runtime into the new location on each run.
RUNTIME_VAR="$(dirname "$RUNTIME")/var"
RPT_DIR="${A3ACC_RPT_DIR:-$COMPAT_DATA/pfx/drive_c/users/steamuser/AppData/Local/Arma 3}"
LAUNCHER_CFG="${A3ACC_LAUNCHER_CFG:-$COMPAT_DATA/pfx/drive_c/users/steamuser/AppData/Local/Arma 3 Launcher}"
STEAM_CFG="${A3ACC_STEAM_CFG:-$STEAM_ROOT/config}"
DOCS_ARMA="$COMPAT_DATA/pfx/drive_c/users/steamuser/Documents/Arma 3"
DOCS_PROFILES="$COMPAT_DATA/pfx/drive_c/users/steamuser/Documents/Arma 3 - Other Profiles"
HOST_PROFILES="${A3ACC_HOST_PROFILES:-$HOME/Documents/Arma 3 - Other Profiles}"
IMAGE="ghcr.io/brettmayson/arma3server/arma3server:v3"
PROJECT="a3acc_probe"

# The engine reads a Windows path. Proton maps Z: to the filesystem root, so the
# scratch profile directory reaches the game as Z:\... and the game creates it.
PROFILES_WIN="Z:$(printf '%s' "$PROFILES" | sed 's|/|\\|g')"

GAME_PORT="${A3ACC_GAME_PORT:-2312}"
TIMEOUT="${A3ACC_TIMEOUT:-420}"
SHOT_TOOL="${A3ACC_SHOT:-}"

MISSION_NAME="a3acc_client_probe.Stratis"
MISSION_SRC="$HERE/probe_mission/$MISSION_NAME"

LINK_A3ACC="$ARMA3/@a3accp_a3acc"
LINK_SELF="$ARMA3/@a3accp_self"
LINK_CBA="$ARMA3/@a3accp_cba"

CLIENT_PID=""
CREATED_LINKS=()
SHOT_USED="none"

say() { printf '%s\n' "$*"; }
die() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

# Only the GAME is a running client. The pattern names arma3_x64.exe, so it never
# matches the Arma 3 launcher, arma3launcher.exe, which is a user interface that
# can sit open harmlessly while the game runs. It does match the proton and wine
# wrapper processes in the game's own launch chain, and that is correct: they
# belong to the game.
client_pids() { pgrep -f 'arma3_x64\.exe' 2>/dev/null || true; }

# The engine writes its reports into the profile folder it was given, and a run
# that ignores -profiles writes them into the Proton prefix. Both locations are
# listed, so the script finds the report either way and archives it.
rpt_list() {
    if [ -d "$PROFILES" ]; then
        find "$PROFILES" -maxdepth 3 -name '*.rpt' -type f 2>/dev/null || true
    fi
    if [ -d "$RPT_DIR" ]; then
        find "$RPT_DIR" -maxdepth 1 -name '*.rpt' -type f 2>/dev/null || true
    fi
}

remove_links() {
    local link
    for link in "${CREATED_LINKS[@]:-}"; do
        [ -n "$link" ] && rm -f "$link" || true
    done
    CREATED_LINKS=()
}

quit_client() {
    [ -z "$CLIENT_PID" ] && return 0
    say "-> quitting the client"
    local pgid
    pgid="$(ps -o pgid= -p "$CLIENT_PID" 2>/dev/null | tr -d ' ')"
    if [ -n "$pgid" ]; then
        kill -TERM -- "-$pgid" 2>/dev/null || true
    else
        kill -TERM "$CLIENT_PID" 2>/dev/null || true
    fi
    for _ in $(seq 1 20); do
        kill -0 "$CLIENT_PID" 2>/dev/null || break
        sleep 0.5
    done
    if kill -0 "$CLIENT_PID" 2>/dev/null; then
        if [ -n "$pgid" ]; then
            kill -KILL -- "-$pgid" 2>/dev/null || true
        else
            kill -KILL "$CLIENT_PID" 2>/dev/null || true
        fi
    fi
    CLIENT_PID=""
}

cleanup() {
    local status=$?
    if [ -n "$CLIENT_PID" ] && kill -0 "$CLIENT_PID" 2>/dev/null; then
        quit_client
    fi
    if command -v docker >/dev/null 2>&1; then
        (cd "$RUN" 2>/dev/null && docker compose -p "$PROJECT" down >/dev/null 2>&1) || true
    fi
    remove_links
    exit "$status"
}
trap cleanup EXIT INT TERM

shot() {
    local out="$1"
    if [ "$SHOT_USED" = "none" ]; then
        if [ -n "$SHOT_TOOL" ]; then
            SHOT_USED="$SHOT_TOOL"
        elif command -v spectacle >/dev/null 2>&1; then
            SHOT_USED="spectacle"
        elif command -v import >/dev/null 2>&1; then
            SHOT_USED="import"
        else
            SHOT_USED="none"
        fi
    fi
    case "$SHOT_USED" in
    spectacle) spectacle -b -n -f -o "$out" >/dev/null 2>&1 || true ;;
    import) import -window root "$out" >/dev/null 2>&1 || true ;;
    *) return 0 ;;
    esac
}

# --- The outside-repo check -------------------------------------------------
# Every tree below lives outside this repository. The run must leave each of them
# as it found it. The snapshot records the relative path, the type, the size and
# the modification time of each entry, so an added file, a removed file or a
# changed file shows up as one changed line.
#
# "prefix-reports" is the report folder the engine uses when it ignores -profiles,
# "steam-config" belongs to the running Steam client, "runtime-var" is the Steam
# Linux Runtime's own scratch overlay, and "server-install" takes the links and the
# key the shared container entrypoint writes. A change to one of those four is
# reported and does not fail the run. A change to any other tree is a fault in this
# script, because nothing in this runner has business writing there.
WATCH_FAIL="game-root game-mpmissions game-links documents-arma3 documents-profiles host-documents-profiles launcher-config"
WATCH_WARN="prefix-reports steam-config runtime-var server-install"

world_snapshot() {
    local label path depth
    while IFS='|' read -r label path depth; do
        [ -n "$label" ] || continue
        if [ -e "$path" ]; then
            find "$path" -mindepth 1 -maxdepth "$depth" \
                -printf "$label\t%P\t%y\t%s\t%T@\n" 2>/dev/null | sort || true
        else
            printf '%s\t(absent)\t\t\t\n' "$label"
        fi
    done <<EOF
game-root|$ARMA3|1
game-mpmissions|$ARMA3/mpmissions|1
documents-arma3|$DOCS_ARMA|3
documents-profiles|$DOCS_PROFILES|3
host-documents-profiles|$HOST_PROFILES|3
prefix-reports|$RPT_DIR|1
steam-config|$STEAM_CFG|1
launcher-config|$LAUNCHER_CFG|2
runtime-var|$RUNTIME_VAR|1
server-install|$SERVER_ROOT|1
EOF
    find "$ARMA3" -maxdepth 1 -mindepth 1 -name '@a3accp_*' \
        -printf 'game-links\t%f\t%y\t%s\t%T@\n' 2>/dev/null | sort || true
}

iso_lines() { awk -F'\t' -v want="$1" '$1 == want { sub(/^[^\t]*\t/, ""); print }' "$2"; }

# Copies every report the run produced into docs/evidence/<stamp>/ and writes the
# probe's readings beside them. A run that failed early still archives what
# exists, because a report is the evidence and the engine may rotate it out.
ARCHIVE=""
archive_reports() {
    ARCHIVE="$EVIDENCE_ROOT/$(date -u +%Y%m%dT%H%M%SZ)"
    mkdir -p "$ARCHIVE"
    local produced archived=0
    while IFS= read -r produced; do
        [ -n "$produced" ] || continue
        cp -p "$produced" "$ARCHIVE/$(basename "$produced")"
        archived=$((archived + 1))
    done < <(comm -13 <(printf '%s\n' "$before") <(rpt_list | sort -u))
    if [ -n "$RPT" ] && [ -f "$RPT" ]; then
        grep "\[A3ACC-PROBE\]" "$RPT" >"$ARCHIVE/readings.txt" 2>/dev/null || : >"$ARCHIVE/readings.txt"
    fi
    say "-> archived $archived report(s) and the probe readings to $ARCHIVE"
}

# Prints one line per watched tree. Sets ISO_FAULT to the first tree this runner
# must not write and did write.
ISO_FAULT=""
isolation_report() {
    local label changes
    ISO_FAULT=""
    say "== outside-repo check =="
    for label in $WATCH_FAIL $WATCH_WARN; do
        changes="$(diff <(iso_lines "$label" "$ISO_BEFORE") <(iso_lines "$label" "$ISO_AFTER") 2>/dev/null || true)"
        if [ -z "$changes" ]; then
            say "   $label: unchanged"
            continue
        fi
        say "   $label: CHANGED"
        printf '%s\n' "$changes" | sed 's/^/      /'
        case " $WATCH_FAIL " in
        *" $label "*)
            [ -n "$ISO_FAULT" ] || ISO_FAULT="$label"
            ;;
        *)
            say "      (this tree belongs to the engine or to the Steam client, not to this runner)"
            ;;
        esac
    done
}

# --- 0. Preflight -----------------------------------------------------------
say "== A3ACC client probe =="

running="$(client_pids)"
if [ -n "$running" ]; then
    say "FAIL: an Arma 3 client is already running (pid $(printf '%s' "$running" | tr '\n' ' '))."
    say "Close it, then run this script again. This script never starts a second instance."
    exit 1
fi
say "-> no Arma 3 client is running"
if pgrep -f 'arma3launcher\.exe' >/dev/null 2>&1; then
    say "   note: the Arma 3 launcher is open. The client is launched directly, so this is only a note."
fi

[ -d "$ARMA3" ] || die "the Arma 3 client folder is not at $ARMA3 (set A3ACC_ARMA3)"
[ -d "$SERVER_ROOT" ] || die "the server install is not at $SERVER_ROOT (set A3ACC_SERVER_ROOT)"
[ -x "$SERVER_ROOT/arma3server_x64" ] || die "$SERVER_ROOT holds no arma3server_x64 (set A3ACC_SERVER_ROOT)"
[ -d "$CBA" ] || die "CBA_A3 is not at $CBA (set A3ACC_CBA)"
[ -x "$PROTON" ] || die "proton is not at $PROTON (set A3ACC_PROTON)"
[ -x "$RUNTIME" ] || die "the Steam Linux Runtime entry point is not at $RUNTIME (set A3ACC_RUNTIME)"
[ -d "$RPT_DIR" ] || say "   note: the prefix report folder is not at $RPT_DIR. The run does not need it, because the reports are written under $PROFILES."
command -v armake >/dev/null 2>&1 || die "armake is not on PATH, and it packs the probe mod"
command -v hemtt >/dev/null 2>&1 || die "hemtt is not on PATH, and it builds the addon"
command -v docker >/dev/null 2>&1 || die "docker is not on PATH, and it runs the dedicated server"

rm -rf "$RUN"
mkdir -p "$SHOTS" "$PROFILES" "$RUN/@a3acc_probe/addons" "$RUN/mods" "$RUN/configs" "$RUN/missions"

# --- 1. Build the addon and the probe mod -----------------------------------
say "-> hemtt build"
(cd "$ROOT" && hemtt build >/dev/null)
[ -d "$ROOT/.hemttout/build" ] || die "hemtt build produced no .hemttout/build"

say "-> armake build the probe mod"
armake build -f "$HERE/probe_mod/addons/a3acc_probe" \
    "$RUN/@a3acc_probe/addons/a3acc_probe.pbo" >/dev/null
cp "$HERE/probe_mod/mod.cpp" "$RUN/@a3acc_probe/mod.cpp"

# --- 2. Choose the mission --------------------------------------------------
# Inspect what is installed before choosing.
say "-> inspecting the installed missions"
installed_playable=""
for dir in "$ARMA3/mpmissions" "$SERVER_ROOT/mpmissions"; do
    [ -d "$dir" ] || continue
    for entry in "$dir"/*; do
        [ -e "$entry" ] || continue
        case "$entry" in
        *.pbo)
            say "   candidate $entry (a packed mission, not inspected)"
            continue
            ;;
        esac
        if [ -f "$entry/mission.sqm" ] && grep -q "isPlayable" "$entry/mission.sqm"; then
            installed_playable="$entry"
            say "   candidate $entry (a folder mission with a playable unit)"
        else
            say "   candidate $entry (no playable unit)"
        fi
    done
done

say "-> mission: $MISSION_NAME"
say "   reason: it is this repository's own minimal Stratis mission, with one"
say "   playable unit and only vanilla addons, so the run is deterministic."
if [ -n "$installed_playable" ]; then
    say "   (the installed playable mission $installed_playable was inspected and"
    say "    rejected, because it belongs to another project and is not controlled here)"
fi
[ -f "$MISSION_SRC/mission.sqm" ] || die "the probe mission is not at $MISSION_SRC"

# The mission is staged inside this runner's own tree and mounted into the
# container as the server's mission folder. The read pass above only reads the
# two installed mission folders, so neither the game folder nor the server
# install gains a mission from this run.
say "-> staging the mission in the runner tree"
say "   source:      $MISSION_SRC"
say "   staged at:   $RUN/missions/$MISSION_NAME"
say "   mounted as:  ./missions -> /arma3/server/mpmissions"
say "   not written: $ARMA3/mpmissions and $SERVER_ROOT/mpmissions"
rm -rf "$RUN/missions/$MISSION_NAME"
cp -a "$MISSION_SRC" "$RUN/missions/"

# --- 3. Assemble the server mod set and config ------------------------------
ln -sfn "$CBA" "$RUN/mods/@cba_a3"
ln -sfn "$ROOT/.hemttout/build" "$RUN/mods/@a3acc"

cat >"$RUN/configs/server.cfg" <<EOF
hostname = "A3ACC probe";
password = "";
passwordAdmin = "";
maxPlayers = 2;
persistent = 1;
loopback = 1;
kickDuplicate = 0;
BattlEye = 0;
verifySignatures = 0;
class Missions {
    class A3ACCProbe { template = "$MISSION_NAME"; difficulty = "custom"; };
};
EOF

cat >"$RUN/config.toml" <<EOF
[server]
binary = "./arma3server_x64"
config = "server.cfg"
profile = "a3accprobe"
world = "Stratis"
mission = "$MISSION_NAME"
limit_fps = 1000
params = "-autoInit -noBattlEye -mod=mods/@a3acc;mods/@cba_a3"
port = $GAME_PORT
skip_install = true
clear_keys = true
cdlc = []

[mods]
local = false
preset = ""

[headless]
clients = 0
profile = "\$profile-hc-\$i"

[steam]
user = ""
password = ""
branch = "public"
branch_password = ""
EOF

cat >"$RUN/docker-compose.yml" <<EOF
services:
  a3acc-probe:
    image: $IMAGE
    platform: linux/amd64
    network_mode: host
    ulimits:
      nofile:
        soft: 1048576
        hard: 1048576
    environment:
      - ARMA3_CONFIG_FILE=/arma3/config.toml
      - ARMA3_SERVER__SKIP_INSTALL=true
      - ARMA3_SERVER__CONFIG=server.cfg
      - ARMA3_SERVER__PROFILE=a3accprobe
      - ARMA3_SERVER__PORT=$GAME_PORT
      - ARMA3_SERVER__PARAMS=-autoInit -noBattlEye -mod=mods/@a3acc;mods/@cba_a3
      - ARMA3_HEADLESS__CLIENTS=0
      - ARMA3_MODS__LOCAL=false
    entrypoint: ["/bin/sh", "/arma3/entrypoint.sh"]
    tmpfs:
      - /arma3/server/configs/profiles
    volumes:
      - ./config.toml:/arma3/config.toml
      - $HERE/ingame/entrypoint.sh:/arma3/entrypoint.sh
      - ./configs:/arma3/server/configs
      - ./mods:/arma3/server/mods
      - ./missions:/arma3/server/mpmissions
      - $SERVER_ROOT:/arma3/server
    restart: "no"
EOF

# --- 4. Start the server ----------------------------------------------------
say "-> starting the dedicated server in Docker on port $GAME_PORT"
(cd "$RUN" && docker compose -p "$PROJECT" down >/dev/null 2>&1) || true
(cd "$RUN" && docker compose -p "$PROJECT" up -d)

say "-> waiting for the server to listen"
ready=0
for _ in $(seq 1 90); do
    if ss -lun 2>/dev/null | grep -q ":$GAME_PORT "; then
        ready=1
        break
    fi
    sleep 1
done
if [ "$ready" -ne 1 ]; then
    say "FAIL: the server did not listen on port $GAME_PORT within 90 s."
    (cd "$RUN" && docker compose -p "$PROJECT" logs --tail 30) || true
    exit 1
fi
say "   server is listening"

# --- 5. Launch the client ---------------------------------------------------
ISO_BEFORE="$RUN/isolation-before.txt"
ISO_AFTER="$RUN/isolation-after.txt"
world_snapshot >"$ISO_BEFORE"

for pair in "$LINK_A3ACC=$ROOT/.hemttout/build" "$LINK_SELF=$RUN/@a3acc_probe" "$LINK_CBA=$CBA"; do
    link="${pair%%=*}"
    target="${pair#*=}"
    rm -f "$link"
    ln -s "$target" "$link"
    CREATED_LINKS+=("$link")
done

CLIENT_ARGS=(
    "-mod=@a3accp_cba;@a3accp_a3acc;@a3accp_self"
    "-connect=127.0.0.1"
    "-port=$GAME_PORT"
    "-profiles=$PROFILES_WIN"
    "-name=A3ACCProbe"
    "-password="
    "-noSplash"
    "-skipIntro"
    "-noPause"
    "-window"
)

say "-> launch command (the client through the Steam Linux Runtime):"
say "   STEAM_COMPAT_DATA_PATH=$COMPAT_DATA \\"
say "   \"$RUNTIME\" --verb=waitforexitandrun -- \\"
say "   \"$PROTON\" waitforexitandrun \"$ARMA3/arma3_x64.exe\" ${CLIENT_ARGS[*]}"
say "   display: DISPLAY=${DISPLAY:-unset} WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-unset}"
say "   the profile, the game config and the reports go to $PROFILES"

before="$(rpt_list | sort -u)"

# The client runs with the game folder as its working directory, because a
# relative -mod= path resolves from the working directory, and the Proton runtime
# can only enter a directory it can see.
launch_pwd="$PWD"
cd "$ARMA3"
DISPLAY="${DISPLAY:-:0}" \
    WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}" \
    STEAM_COMPAT_DATA_PATH="$COMPAT_DATA" \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_ROOT" \
    SteamAppId=107410 \
    SteamGameId=107410 \
    setsid "$RUNTIME" --verb=waitforexitandrun -- "$PROTON" waitforexitandrun "$ARMA3/arma3_x64.exe" "${CLIENT_ARGS[@]}" \
    >"$RUN/client.log" 2>&1 &
CLIENT_PID=$!
cd "$launch_pwd"
say "-> client started (pid $CLIENT_PID)"

say "-> waiting for a new client report"
RPT=""
for _ in $(seq 1 300); do
    after="$(rpt_list | sort -u)"
    new="$(comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after") || true)"
    if [ -n "$new" ]; then
        RPT="$(printf '%s\n' "$new" | tail -n 1)"
        break
    fi
    if ! kill -0 "$CLIENT_PID" 2>/dev/null; then
        break
    fi
    sleep 1
done
if [ -z "$RPT" ]; then
    if kill -0 "$CLIENT_PID" 2>/dev/null; then
        say "FAIL: the client started but wrote no report within 300 s."
    else
        say "FAIL: the client exited before it wrote a report."
    fi
    shot "$SHOTS/client-failed.png"
    say "   a screenshot of the desktop is at $SHOTS/client-failed.png (tool: $SHOT_USED)"
    tail -n 30 "$RUN/client.log" || true
    archive_reports
    exit 1
fi
say "   client report: $RPT"

# --- 6. Follow the report, screenshot each step, wait for DONE ---------------
say "-> following the report for the DONE marker (timeout ${TIMEOUT}s)"
seen_steps=0
done_marker=0
deadline=$(($(date +%s) + TIMEOUT))
while [ "$(date +%s)" -lt "$deadline" ]; do
    steps="$(grep -c "\[A3ACC-PROBE\] STEP " "$RPT" 2>/dev/null || true)"
    while [ "$seen_steps" -lt "${steps:-0}" ]; do
        seen_steps=$((seen_steps + 1))
        shot "$SHOTS/step-$(printf '%02d' "$seen_steps").png"
        say "   screenshot step $seen_steps -> $SHOTS/step-$(printf '%02d' "$seen_steps").png"
    done
    if grep -q "\[A3ACC-PROBE\] DONE" "$RPT" 2>/dev/null; then
        done_marker=1
        break
    fi
    if ! kill -0 "$CLIENT_PID" 2>/dev/null; then
        break
    fi
    sleep 0.5
done

if [ "$done_marker" -eq 1 ]; then
    say "   the DONE marker appeared after $seen_steps step(s)"
    sleep 2
else
    say "FAIL: the DONE marker did not appear within ${TIMEOUT}s. This is a timeout, not a pass."
    shot "$SHOTS/timeout.png"
    say "   a screenshot of the desktop at the timeout is at $SHOTS/timeout.png (tool: $SHOT_USED)"
fi

# --- 7. Quit the client, stop the server, remove the game-folder links ------
quit_client
(cd "$RUN" && docker compose -p "$PROJECT" logs >"$RUN/server.log" 2>&1) || true
(cd "$RUN" && docker compose -p "$PROJECT" down >/dev/null 2>&1) || true

# The three @a3accp_* links are the only thing this runner ever creates in the
# game folder. Remove them here, so the check below sees the game folder as the
# run found it.
remove_links
say "-> removed the game-folder links (@a3accp_cba, @a3accp_a3acc, @a3accp_self)"

# --- 8. Archive the reports, then check the outside-repo trees ---------------
archive_reports

world_snapshot >"$ISO_AFTER"
isolation_report >"$ARCHIVE/isolation.txt"
cat "$ARCHIVE/isolation.txt"

# --- 9. Gate the report and print the summary -------------------------------
say ""
say "-> python3 tests/check_client_rpt.py"
gate_rc=0
python3 "$HERE/check_client_rpt.py" "$RPT" || gate_rc=$?

say ""
say "== readings =="
grep "\[A3ACC-PROBE\]" "$RPT" | sed 's/^[[:space:]]*//' || true

say ""
say "== checks =="
grep "\[A3ACC-PROBE\] VERDICT " "$RPT" | while read -r line; do
    rest="${line#*VERDICT }"
    check="${rest%% *}"
    rest="${rest#* }"
    state="${rest%% *}"
    detail="${rest#* }"
    case "$state" in
    PASS) verdict="passed" ;;
    FAIL) verdict="FAILED" ;;
    *) verdict="needs a judgement from the images" ;;
    esac
    printf '%-28s %-45s %s\n' "$check" "$verdict" "$detail"
done || true

say ""
say "== artefacts =="
say "client report: $RPT"
say "archive:       $ARCHIVE"
say "screenshots:   $SHOTS ($seen_steps image(s), tool: $SHOT_USED)"
say "client log:    $RUN/client.log"
say "server log:    $RUN/server.log"

if [ "$done_marker" -ne 1 ]; then
    say ""
    say "RESULT: FAIL (the probe timed out before the DONE marker)"
    exit 1
fi
if [ "$gate_rc" -ne 0 ]; then
    say ""
    say "RESULT: FAIL (tests/check_client_rpt.py exited $gate_rc)"
    exit 1
fi
if [ -n "$ISO_FAULT" ]; then
    say ""
    say "RESULT: FAIL (the run changed an outside-repo tree: $ISO_FAULT)"
    exit 1
fi

say ""
say "RESULT: PASS (the probe finished, the report gate passed, and no outside-repo"
say "tree changed). A rendered claim still needs the eye judgements named above,"
say "from the images."
exit 0
