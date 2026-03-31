# claude-handoff

Claude Codeのコンテキストが長くなったとき、引き継ぎプロンプトを生成して新セッションに移行するプラグイン。

## Requirements

- Claude Code CLI
- Python 3 (used for JSON escaping in hooks)

## Install

```bash
claude plugin install claude-handoff
```

## Usage

### `/handoff` — 引き継ぎして新セッション起動

1. 現在のタスク状況・変更ファイル・プランを収集
2. セッションサマリを自動生成
3. 追加メッセージを入力（任意）
4. `~/.claude/handoffs/` に引き継ぎファイルを保存
5. `claude update` を実行
6. ユーザーが以下のコマンドで新セッションを起動
7. SessionStartフックが引き継ぎコンテキストを自動注入 → Claudeがすぐに作業再開

```
あなた: /handoff
Claude: (タスク・変更ファイル・サマリを収集)
Claude: 引き継ぎに追加したいメッセージはありますか？
あなた: 次はテストを書いてほしい
Claude: 引き継ぎファイルを保存しました。新しいセッションを開始してください：
        claude "前回の引き継ぎを確認して、作業を再開してください"
あなた: (セッション終了後) claude "前回の引き継ぎを確認して、作業を再開してください"
新セッション: (引き継ぎコンテキスト自動注入 → 即座に作業再開！)
```

### Stop Hook（セーフティネット）

セッション終了時に未完了タスクや大きな変更があれば `/handoff` を提案します。

## Handoff Files

引き継ぎファイルは `~/.claude/handoffs/` にタイムスタンプ付きで保存されます。
新セッション起動時、**10分以内**のファイルのみ自動読み込みされます（古い引き継ぎが不意に注入されるのを防ぎます）。
