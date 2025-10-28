# Gitリポジトリ一括更新ツール

指定したディレクトリ配下にあるすべてのGitリポジトリを一括で最新にするPythonスクリプトです。

## 機能

- 指定ディレクトリ配下のすべてのGitリポジトリを自動検索
- 各リポジトリで `git fetch` と `git pull` を自動実行
- カラー出力で見やすい結果表示
- 未コミットの変更があるリポジトリは自動的にスキップ
- 更新結果のサマリー表示

## 必要要件

- Python 3.6以上
- Git がインストールされていること

## 使用方法

### 基本的な使い方

```bash
python update_all_repos.py <ディレクトリパス>
```

### 例

**カレントディレクトリ配下を更新:**
```bash
python update_all_repos.py .
```

**特定のディレクトリ配下を更新:**
```bash
python update_all_repos.py /path/to/projects
```

**Windowsドライブ配下を更新:**
```bash
python update_all_repos.py C:\Projects
```

**ドライブ全体を更新:**
```bash
python update_all_repos.py C:\
python update_all_repos.py D:\
```

### スクリプトを直接実行（Linux/Mac）

```bash
chmod +x update_all_repos.py
./update_all_repos.py /path/to/projects
```

## 出力例

```
=== Gitリポジトリ一括更新ツール ===
検索パス: /home/user/projects

Gitリポジトリを検索中...
✓ 5個のリポジトリを発見しました

[1/5] project1
    パス: /home/user/projects/project1
    ブランチ: main | リモート: origin
    ✓ Already up to date

[2/5] project2
    パス: /home/user/projects/project2
    ブランチ: develop | リモート: origin
    ✓ 更新しました

[3/5] project3
    パス: /home/user/projects/project3
    ブランチ: main | リモート: origin
    ⚠ 未コミットの変更があります - スキップします

=== 更新結果 ===
成功: 2
スキップ: 1
失敗: 0
合計: 5
```

## 動作仕様

### リポジトリの検索

- 指定されたディレクトリ配下を再帰的に検索
- `.git` ディレクトリを持つディレクトリをGitリポジトリとして認識
- ネストされたリポジトリ（サブモジュールなど）は親リポジトリのみを処理

### 更新処理

各リポジトリに対して以下の処理を実行：

1. **状態確認**: 現在のブランチ、リモート、ステータスを取得
2. **変更チェック**: 未コミットの変更がある場合はスキップ
3. **更新実行**: `git fetch` と `git pull` を実行（タイムアウト: 60秒）

### スキップ条件

以下の場合、リポジトリの更新をスキップします：

- 未コミットの変更がある
- ステージングされた変更がある
- 新規作成されたファイルがある

### 終了コード

- `0`: すべて成功（スキップを含む）
- `1`: 1つ以上のリポジトリで更新に失敗

## トラブルシューティング

### "Permission denied" エラー

リモートリポジトリへのアクセス権限がない場合、SSH鍵やHTTPSの認証情報を確認してください。

### タイムアウトエラー

大きなリポジトリや通信速度が遅い場合、タイムアウト（60秒）に達することがあります。
その場合は、スクリプトの `timeout=60` の値を増やしてください。

### "Already up to date" が表示されない

リポジトリが既に最新の場合でも、Gitのバージョンによってメッセージが異なることがあります。
スクリプトは両方のメッセージ形式に対応しています。

## カスタマイズ

### タイムアウト時間の変更

`update_repository()` 関数内の `timeout=60` を変更：

```python
result = subprocess.run(
    ['git', 'pull'],
    cwd=repo_path,
    capture_output=True,
    text=True,
    timeout=120  # 120秒に変更
)
```

### 未コミット変更があるリポジトリも更新

リスクがありますが、以下のコメントアウトを外すことで強制更新も可能です：

```python
# 未コミットの変更がある場合の処理を変更
if status:
    # print(f"    {Colors.WARNING}⚠ 未コミットの変更があります - スキップします{Colors.ENDC}")
    # skip_count += 1
    # print()
    # continue
    print(f"    {Colors.WARNING}⚠ 未コミットの変更がありますが続行します{Colors.ENDC}")
```

## ライセンス

このスクリプトは自由に使用、改変、配布できます。

## 注意事項

- このスクリプトは各リポジトリで `git pull` を実行します
- 未コミットの変更があるリポジトリは自動的にスキップされます
- リモートブランチが削除されている場合など、マージコンフリクトが発生する可能性があります
- 重要なデータは事前にバックアップすることを推奨します
