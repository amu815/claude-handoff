---
name: handoff
description: Generate a handoff prompt summarizing current work and launch a fresh Claude Code session. Use when context is getting long or you want to continue work in a new session. Trigger phrases - "handoff", "hand off", "引き継ぎ", "context is long", "start fresh session"
---

# Handoff — Session Transfer

Generate a handoff document capturing current work state, save it, then launch an updated new Claude Code session that auto-loads the context.

## Process

Execute these steps in order:

### Step 1: Collect Task Status

Use the TaskList tool to get all current tasks. Format as:
- `[x]` for completed tasks
- `[ ]` for pending/in-progress tasks

If no tasks exist, write "(No tasks tracked in this session)".

### Step 2: Collect Changed Files

Run:
```bash
git status --porcelain 2>/dev/null && echo "---" && git diff --stat 2>/dev/null
```

If not a git repo or no changes, write "(No git changes or not a git repository)".

### Step 3: Collect Plan

Check if `tasks/todo.md` exists. If it does, read its contents. If not, write "(No plan file found)".

### Step 4: Generate Session Summary

Write a concise summary (5-10 sentences) of what was accomplished in this session:
- What was the goal?
- What was completed?
- What is still in progress?
- Any key decisions made?
- Any blockers or issues?

Write this in the same language the user has been using in the conversation.

### Step 5: Ask for Additional Notes

Ask the user:

**引き継ぎに追加したいメッセージはありますか？（空Enterでスキップ）**

Wait for the user's response. If they provide text, include it. If empty or they say skip, write "(None)".

### Step 6: Save Handoff File

Create the handoff directory and save the file:

```bash
mkdir -p ~/.claude/handoffs
```

Write the handoff document to `~/.claude/handoffs/YYYY-MM-DDTHH-MM.md` using the current timestamp. Use this format:

```markdown
# Handoff: {timestamp}

## Session Summary
{summary from step 4}

## Task Status
{tasks from step 1}

## Changed Files
{git output from step 2}

## Plan
{plan from step 3}

## Additional Notes
{user message from step 5}
```

### Step 7: Launch New Session

Tell the user the handoff is ready, then execute:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/handoff.sh "{handoff_file_path}"
```

**IMPORTANT:** This will update Claude Code and start a new session. The SessionStart hook will automatically inject the handoff context.
