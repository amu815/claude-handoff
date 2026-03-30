# claude-handoff

Claude Codeのコンテキストが長くなったとき、引き継ぎプロンプトを生成して新セッションに移行するプラグイン。

## Requirements

- Claude Code CLI
- Python 3 (used for JSON escaping in hooks)

## Install

```bash
claude plugin install github:amu815/claude-handoff
```

## Usage

### `/handoff` — 引き継ぎして新セッション起動

1. 現在のタスク状況・変更ファイル・プランを収集
2. セッションサマリを自動生成
3. 追加メッセージを入力（任意）
4. `~/.claude/handoffs/` に引き継ぎファイルを保存
5. `claude update` → 新セッション起動
6. 新セッションで引き継ぎコンテキストを自動注入

### Stop Hook（セーフティネット）

セッション終了時に未完了タスクや大きな変更があれば `/handoff` を提案します。

## Handoff Files

引き継ぎファイルは `~/.claude/handoffs/` にタイムスタンプ付きで保存されます。
新セッション起動時、10分以内のファイルのみ自動読み込みされます。
