#!/bin/bash
# SessionStart hook: inject latest handoff context into new session
# Only injects handoff files younger than 10 minutes (600 seconds)

command -v python3 >/dev/null 2>&1 || exit 0

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

The following is a handoff document from the previous session. When the user sends their first message, start by:
1. Briefly summarize what was being worked on (2-3 sentences)
2. List any incomplete tasks
3. Suggest the next action to take

If the user's first message is just a greeting or 'continue', proactively resume the work described below.

"
  FULL="${PREFIX}${CONTENT}"
  ESCAPED=$(printf '%s' "$FULL" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
  echo "{\"systemMessage\": ${ESCAPED}}"
fi
