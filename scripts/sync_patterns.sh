#!/usr/bin/env bash
# sync_patterns.sh — Bootstrap script for patterns channel subscription
#
# Usage:
#   ./scripts/sync_patterns.sh [<repo> [<channel>]]
#
# Environment:
#   PATTERNS_REPO    — GitHub org/repo  (default: orchestras/dev-patterns)
#   PATTERNS_CHANNEL — Channel name     (default: python3a)
#
# Install in a new repo:
#   gh api repos/orchestras/dev-patterns/contents/scripts/sync_patterns.sh \
#     --jq '.content' | base64 -d > scripts/sync_patterns.sh && chmod +x scripts/sync_patterns.sh
#
# Or with curl (public repo):
#   curl -sSfL \
#     https://raw.githubusercontent.com/orchestras/dev-patterns/main/scripts/sync_patterns.sh \
#     -o scripts/sync_patterns.sh && chmod +x scripts/sync_patterns.sh

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
DEFAULT_REPO="orchestras/dev-patterns"
PATTERNS_REPO="${PATTERNS_REPO:-${1:-${DEFAULT_REPO}}}"
PATTERNS_CHANNEL="${PATTERNS_CHANNEL:-${2:-python3a}}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "${SCRIPT_DIR}/..")"
SYNC_PY="${SCRIPT_DIR}/sync_patterns.py"

# ── Terminal colours ──────────────────────────────────────────────────────────
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}${BOLD}Patterns Bootstrap${RESET}"
echo -e "  Repo:    ${PATTERNS_REPO}"
echo -e "  Channel: ${PATTERNS_CHANNEL}"
echo ""

# ── Python check ─────────────────────────────────────────────────────────────
PYTHON=""
for candidate in python3 python python3.13 python3.12; do
  if command -v "$candidate" &>/dev/null; then
    version=$("$candidate" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    major="${version%%.*}"
    minor="${version##*.}"
    if [ "$major" -ge 3 ] && [ "$minor" -ge 12 ] 2>/dev/null; then
      PYTHON="$candidate"
      break
    fi
  fi
done

if [ -z "$PYTHON" ]; then
  echo -e "${YELLOW}⚠  Python 3.12+ not found.  Install it first:${RESET}"
  echo "   https://github.com/jdx/mise — mise install python 3.13"
  exit 1
fi

echo -e "  Using Python: $($PYTHON --version)"
echo ""

# ── Download sync_patterns.py if missing ─────────────────────────────────────
if [ ! -f "${SYNC_PY}" ]; then
  echo -e "  ⟳ Downloading sync_patterns.py…"
  SYNC_PY_PATH="scripts/sync_patterns.py"

  # Prefer gh CLI for authenticated/private repos
  if command -v gh &>/dev/null; then
    gh api "repos/${PATTERNS_REPO}/contents/${SYNC_PY_PATH}" \
      --jq '.content' 2>/dev/null | base64 -d > "${SYNC_PY}" 2>/dev/null \
      && [ -s "${SYNC_PY}" ] \
      || {
        # gh api succeeded but content was empty / failed — clear and fall through
        rm -f "${SYNC_PY}"
      }
  fi

  # Fallback to curl / wget
  if [ ! -s "${SYNC_PY}" ]; then
    RAW_URL="https://raw.githubusercontent.com/${PATTERNS_REPO}/main/${SYNC_PY_PATH}"
    if command -v curl &>/dev/null; then
      curl -sSfL "${RAW_URL}" -o "${SYNC_PY}" || rm -f "${SYNC_PY}"
    elif command -v wget &>/dev/null; then
      wget -qO "${SYNC_PY}" "${RAW_URL}" || rm -f "${SYNC_PY}"
    fi
  fi

  if [ ! -s "${SYNC_PY}" ]; then
    echo -e "${YELLOW}⚠  Could not download sync_patterns.py.${RESET}"
    echo "   Try: gh api repos/${PATTERNS_REPO}/contents/scripts/sync_patterns.py --jq '.content' | base64 -d > ${SYNC_PY}"
    exit 1
  fi

  chmod +x "${SYNC_PY}"
  echo -e "  ${GREEN}✓ sync_patterns.py downloaded${RESET}"
fi

# ── Run the Python sync script ────────────────────────────────────────────────
exec "${PYTHON}" "${SYNC_PY}" \
  --repo    "${PATTERNS_REPO}" \
  --channel "${PATTERNS_CHANNEL}" \
  --root    "${ROOT}" \
  "$@"
