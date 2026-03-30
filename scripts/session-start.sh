#!/bin/bash
# SessionStart hook: inject latest handoff context into new session
# Only injects handoff files younger than 10 minutes (600 seconds)

HANDOFF_DIR="$HOME/.claude/handoffs"

[ -d "$HANDOFF_DIR" ] || exit 0

LATEST=$(ls -t "$HANDOFF_DIR"/*.md 2>/dev/null | head -1)
[ -n "$LATEST" ] || exit 0

if [ "$(uname)" = "Darwin" ]; then
  FILE_TIME=$(stat -f %m "$LATEST")
else
  FILE_TIME=$(stat -c %Y "$LATEST")
fi
NOW=$(date +%s)
AGE=$(( NOW - FILE_TIME ))

if [ "$AGE" -lt 600 ]; then
  CONTENT=$(cat "$LATEST")
  PREFIX="=== HANDOFF FROM PREVIOUS SESSION ===

The following is a handoff document from the previous session. Review it and continue the work described.

"
  FULL="${PREFIX}${CONTENT}"
  ESCAPED=$(printf '%s' "$FULL" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
  echo "{\"systemMessage\": ${ESCAPED}}"
fi
