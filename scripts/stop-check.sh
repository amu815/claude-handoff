#!/bin/bash
# Stop hook: suggest /handoff if there are incomplete tasks or uncommitted changes

SUGGEST=false
REASONS=""

# Check for uncommitted git changes (if in a git repo)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  CHANGED=$(git status --porcelain 2>/dev/null | wc -l)
  if [ "$CHANGED" -gt 5 ]; then
    SUGGEST=true
    REASONS="${REASONS}\n- ${CHANGED} uncommitted file changes detected"
  fi
fi

# Check for tasks/todo.md with unchecked items
if [ -f "tasks/todo.md" ]; then
  UNCHECKED=$(grep -c '^\s*- \[ \]' tasks/todo.md 2>/dev/null || echo 0)
  if [ "$UNCHECKED" -gt 0 ]; then
    SUGGEST=true
    REASONS="${REASONS}\n- ${UNCHECKED} incomplete items in tasks/todo.md"
  fi
fi

if [ "$SUGGEST" = true ]; then
  MSG="Before ending this session, consider running /handoff to create a handoff prompt for the next session.\n\nReasons:${REASONS}"
  ESCAPED=$(printf '%s' "$MSG" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
  echo "{\"decision\": \"block\", \"reason\": ${ESCAPED}}"
else
  echo '{"decision": "approve"}'
fi
