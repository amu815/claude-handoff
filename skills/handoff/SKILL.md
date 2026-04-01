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

### Step 5: Ask for Additional Notes and Model Selection

Ask the user both questions at once:

**引き継ぎに追加したいメッセージはありますか？（空Enterでスキップ）**
**次のセッションで使うモデルを選んでください（空Enterでデフォルト）：**
- `opus` — Claude Opus 4.6
- `sonnet` — Claude Sonnet 4.6
- `haiku` — Claude Haiku 4.5
- またはフルモデルID（例: `claude-sonnet-4-6`）

**effortレベルを選んでください（空Enterでデフォルト）：**
- `low` — 軽量・高速
- `medium` — バランス
- `high` — 高品質
- `max` — 最大限

Wait for the user's response. If they provide notes, include them. If empty or they say skip, write "(None)".
Save the selected model and effort level (if any) for use in Step 7.

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

### Step 7: Update and Guide User

After saving the handoff file:

1. Run `claude update` to ensure the latest version is installed:

```bash
claude update 2>&1 || echo "(Update skipped or failed)"
```

2. Tell the user the handoff is complete and instruct them to start a new session. Build the command by appending flags only for options the user selected in Step 5:

- Model selected → add `--model {model}`
- Effort selected → add `--effort {level}`

```
引き継ぎファイルを保存しました: ~/.claude/handoffs/{filename}

新しいセッションを開始するには、このセッションを終了してから以下を実行してください：

claude {--model model} {--effort level} "前回の引き継ぎを確認して、作業を再開してください"

SessionStartフックが引き継ぎコンテキストを自動注入し、Claudeがすぐに作業を再開します。
```

Omit any flag that was not selected (e.g., if only effort was chosen: `claude --effort high "..."`). If neither was selected, output just `claude "..."`.

**NOTE:** Claude Code's Bash tool runs in a non-interactive subprocess, so `exec claude` cannot replace the current session. The user must manually start the new session after this one ends.
