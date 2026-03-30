#!/bin/bash
# Handoff launcher: update Claude Code and start a new session
# Called by the /handoff skill after generating the handoff file

HANDOFF_FILE="$1"

echo ""
echo "================================================"
echo "  Handoff complete!"
echo "  Saved to: ${HANDOFF_FILE}"
echo "================================================"
echo ""

echo "Updating Claude Code..."
claude update 2>&1 || echo "(Update skipped or failed, continuing...)"

echo ""
echo "Starting new session..."
exec claude
