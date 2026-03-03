# lib.sh — bootstrap helper for standalone scripts.
# Usage: . "${0%/*}/../core/lib.sh"
#
# Provides logging (info, success, warn, error) and core utils.
# Falls back to plain printf if runtime core is unavailable.

_RUNTIME_LIB_ROOT="${_RUNTIME_LIB_ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"

. "$_RUNTIME_LIB_ROOT/core/log.sh" 2>/dev/null || {
    info() { printf 'info: %s\n' "$*"; }
    success() { printf 'success: %s\n' "$*"; }
    warn() { printf 'warn: %s\n' "$*" >&2; }
    error() { printf 'error: %s\n' "$*" >&2; }
}

. "$_RUNTIME_LIB_ROOT/core/utils.sh" 2>/dev/null || true
