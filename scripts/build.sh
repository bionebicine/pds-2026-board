#!/usr/bin/env bash
# Build the bionebicine_pds_2026 board against an existing CircuitPython checkout.
#
# Used by both .github/workflows/build-and-release.yml and local development, so there's
# exactly one place that knows how to build this board - CI and local builds can't drift
# apart from each other.
#
# Usage: scripts/build.sh <path-to-circuitpython-checkout>
#
# <path-to-circuitpython-checkout> must already have whatever ref you want to build against
# checked out (main, a tag, a specific commit) - this script never touches which ref is
# checked out, and never commits anything into that checkout. It just copies
# boards/bionebicine_pds_2026 in fresh (overwriting any previous copy) and builds. That
# checkout can be a long-lived local cache you re-fetch/reset over time; it never needs its
# own branch or commit for this board.
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path-to-circuitpython-checkout>" >&2
    exit 1
fi

CP_DIR=$(cd "$1" && pwd)
REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BOARD=bionebicine_pds_2026

if [ ! -f "$CP_DIR/py/version.py" ]; then
    echo "error: $CP_DIR doesn't look like a CircuitPython checkout (py/version.py not found)" >&2
    exit 1
fi

# Defensive, harmless on any machine where this path doesn't exist: on Mike's own machine,
# the fed_pds_nebulizer project venv gets auto-activated by the shell profile regardless of
# cwd, which repeatedly broke ESP-IDF's own Python venv bootstrap during development of this
# board. Stripping it here means this script works the same way regardless of which shell
# state it's invoked from.
unset VIRTUAL_ENV
PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "fed_pds_nebulizer/.venv" | paste -sd: -)
export PATH

# That venv happened to also be shadowing problems with whatever bare `python3` is first on
# PATH without it - confirmed two different ways on this machine: Apple's bundled
# /usr/bin/python3 (3.9.6) is too old for ESP-IDF, while Homebrew's generic `python3` symlink
# floats to whatever's newest installed (3.15 as of this writing) - newer than some of this
# project's own pinned build dependencies support yet (minify_html's PyO3-based wheel,
# specifically). ESP-IDF's own tools/detect_python.sh checks the bare name `python3` first,
# before any versioned name like python3.14, so just putting python3.14's own directory on
# PATH isn't enough: that directory has no bare `python3` of its own (only python@3.14's
# versioned binaries), so the search falls through PAST it to the floating one anyway. A
# shim directory providing both `python` and `python3`, pointing at a known-good interpreter
# (preferring the specific python3.14 this project has been validated against all session,
# over whatever generic python3 happens to be newest), closes that gap directly. Harmless
# everywhere this isn't needed: Linux CI already has a qualifying, stable python3 first on
# PATH, so GOOD_PYTHON3 there just re-confirms what's already in place.
GOOD_PYTHON3=""
if command -v python3.14 >/dev/null 2>&1; then
    GOOD_PYTHON3=$(command -v python3.14)
elif python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then
    GOOD_PYTHON3=$(command -v python3)
else
    for candidate in /opt/homebrew/bin/python3 /usr/local/bin/python3; do
        if [ -x "$candidate" ] && "$candidate" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then
            GOOD_PYTHON3="$candidate"
            break
        fi
    done
fi
if [ -n "$GOOD_PYTHON3" ]; then
    PYSHIM_DIR=$(mktemp -d)
    ln -s "$GOOD_PYTHON3" "$PYSHIM_DIR/python3"
    ln -s "$GOOD_PYTHON3" "$PYSHIM_DIR/python"
    PATH="$PYSHIM_DIR:$PATH"
    export PATH
fi

echo "==> Copying $BOARD into $CP_DIR"
rm -rf "$CP_DIR/ports/espressif/boards/$BOARD"
cp -r "$REPO_ROOT/boards/$BOARD" "$CP_DIR/ports/espressif/boards/$BOARD"

cd "$CP_DIR"

export IDF_PATH="$CP_DIR/ports/espressif/esp-idf"
export IDF_TOOLS_PATH="$CP_DIR/.idf_tools"
export ESP_ROM_ELF_DIR="$CP_DIR/.idf_tools"

echo "==> Initializing esp-idf submodules"
git submodule update --init --depth=1 --recursive "$IDF_PATH"

echo "==> Fetching remaining submodules"
python3 tools/ci_fetch_deps.py "$BOARD"

echo "==> Installing ESP-IDF tools"
"$IDF_PATH/install.sh"
# Invoked via python3 explicitly, not relying on this script's own `#!/usr/bin/env python`
# shebang: some systems (confirmed on macOS without a bare `python` on PATH) fail that
# shebang resolution outright, even with a working python3 available. install.sh itself
# avoids this internally; this call needs the same treatment since it's invoked directly.
python3 "$IDF_PATH/tools/idf_tools.py" install ninja
# shellcheck source=/dev/null
source "$IDF_PATH/export.sh"

echo "==> Installing Python dependencies"
python3 -u tools/ci_set_idf_constraint.py
if [ -n "${IDF_CONSTRAINT_FILE:-}" ] && [ -f "$IDF_CONSTRAINT_FILE" ]; then
    pip install -c "$IDF_CONSTRAINT_FILE" -r requirements-dev.txt
else
    pip install -r requirements-dev.txt
fi

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)

echo "==> Building mpy-cross"
make -C mpy-cross -j"$NPROC"

echo "==> Building $BOARD"
make -j"$NPROC" BOARD="$BOARD" -C ports/espressif

echo "==> Done: $CP_DIR/ports/espressif/build-$BOARD/firmware.bin"
