#!/usr/bin/env sh
set -eu

PROJECT_TAB_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
NODE_PATH=$(command -v node || true)

if [ -z "$NODE_PATH" ]; then
  echo "Node.js 24 or later was not found. Install Node.js and run this launcher again." >&2
  exit 1
fi

NODE_VERSION=$($NODE_PATH --version)
NODE_MAJOR=$(printf '%s' "$NODE_VERSION" | sed 's/^v//' | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 24 ]; then
  echo "Project TAB requires Node.js 24 or later. Found $NODE_VERSION." >&2
  exit 1
fi

TAB_LOCAL_PORT=${PORT:-8080}
if [ "${TAB_ALLOW_LAN:-0}" = "1" ]; then
  HOST=0.0.0.0
else
  HOST=127.0.0.1
fi

export HOST
export PORT=$TAB_LOCAL_PORT
export TAB_DB_PATH=${TAB_DB_PATH:-"$PROJECT_TAB_ROOT/data/project-tab.db"}
mkdir -p "$PROJECT_TAB_ROOT/data"

TAB_LOCAL_URL="http://127.0.0.1:$TAB_LOCAL_PORT"
printf 'Project TAB - Test a Breach\n'
printf 'Runtime:  %s\n' "$NODE_VERSION"
printf 'Database: %s\n' "$TAB_DB_PATH"
printf 'Local URL: %s\n' "$TAB_LOCAL_URL"
printf 'Keep this terminal open. Press Ctrl+C to stop Project TAB.\n'

if [ "${TAB_NO_BROWSER:-0}" != "1" ]; then
  (
    sleep 1
    if command -v open >/dev/null 2>&1; then
      open "$TAB_LOCAL_URL" >/dev/null 2>&1 || true
    elif command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$TAB_LOCAL_URL" >/dev/null 2>&1 || true
    fi
  ) &
fi

cd "$PROJECT_TAB_ROOT"
exec "$NODE_PATH" server.js
