# Everything（voidtools）の便利な使い方 完全ガイド

## Executive Summary

**Everything** は [voidtools](https://www.voidtools.com/) が開発した、Windows 向けの超高速ファイル名検索ツールです。Windows の NTFS インデックスを直接読み込むため、数百万ファイルを**ほぼ瞬時**に検索できます。単純なファイル名検索だけでなく、正規表現、サイズ・日付フィルター、重複ファイル検索、コマンドラインインターフェース、HTTP サーバー機能など、多彩な活用方法があります。

---

## 1. 基本的な使い方

### インストール・起動

- タスクトレイに常駐し、ホットキー（デフォルト: なし → 自分で設定）で即座に呼び出せる[^1]
- 初回起動時に全 NTFS ドライブをインデックス化（数秒～数十秒）
- その後はリアルタイムで更新されるため、常に最新の状態

### 検索ボックスの基本操作

| 操作 | 内容 |
|------|------|
| 部分文字列入力 | ファイル名に含まれる文字を入力するだけ |
| `d:` | D ドライブのみに絞り込み |
| `d:\downloads\` | 特定フォルダ内に絞り込み |
| `"c:\program files\"` | スペースを含むパスは二重引用符で囲む |
| `documents\` | `documents` という名前のフォルダ内を検索 |
| `\work order` | `work` フォルダ内で `order` を含むファイルを検索 |

[^1]: https://www.voidtools.com/support/everything/using_everything/

---

## 2. 検索構文（Syntax）

### 論理演算子

| 記号 | 意味 | 例 |
|------|------|-----|
| スペース | AND | `report 2024` → 両方含む |
| `\|` | OR | `jpg\|png` → どちらか含む |
| `!` | NOT | `report !draft` → draft を除く |
| `< >` | グループ化 | `<report\|summary> 2024` |
| `" "` | 完全フレーズ | `"annual report"` |

[^2]: https://www.voidtools.com/support/everything/searching/

### ワイルドカード

| 記号 | 意味 |
|------|------|
| `*` | 0文字以上の任意文字 |
| `?` | 任意の1文字 |

例: `report_202?.xlsx` → report_2020.xlsx ～ report_2029.xlsx にマッチ

### モディファイア（修飾子）

検索語の前に付けてマッチ方法を変更します[^2]：

| モディファイア | 説明 |
|---------------|------|
| `case:` | 大文字・小文字を区別 |
| `file:` / `folder:` | ファイルのみ / フォルダのみ |
| `path:` | フルパスも含めて検索 |
| `regex:` | 正規表現を有効化 |
| `wfn:` | ファイル名全体に一致 |
| `wholeword:` | 単語単位で一致 |

例: `file: case: Report` → 大文字小文字を区別しファイルのみ検索

---

## 3. ファイルタイプ別マクロ

種類別に素早く絞り込めるマクロが用意されています[^2]：

| マクロ | 対象 |
|--------|------|
| `audio:` | 音楽ファイル（mp3, flac, wav など） |
| `video:` | 動画ファイル（mp4, mkv, avi など） |
| `pic:` | 画像ファイル（jpg, png, gif など） |
| `doc:` | ドキュメント（pdf, docx, xlsx など） |
| `exe:` | 実行ファイル |
| `zip:` | 圧縮ファイル（zip, 7z, rar など） |

例: `audio: beatles` → Beatles 関連の音楽ファイルを即検索

---

## 4. 日付フィルター

### よく使う日付検索

```
dm:today          # 今日変更されたファイル
dm:thisweek       # 今週変更されたファイル
dm:lastmonth      # 先月変更されたファイル
dc:2024           # 2024年に作成されたファイル
dm:2024-01-01..2024-03-31  # 範囲指定
```

| 関数 | 説明 |
|------|------|
| `dm:` / `datemodified:` | 更新日 |
| `dc:` / `datecreated:` | 作成日 |
| `da:` / `dateaccessed:` | アクセス日 |
| `dr:` / `daterun:` | 実行日 |

### 日付定数

`today` / `yesterday` / `thisweek` / `lastweek` / `thismonth` / `lastmonth` / `thisyear` など直感的な指定が可能[^2]

**実用例**: 最近変更したファイルをリアルタイム監視  
→ `dm:today` で検索し、結果リストを「更新日時」降順でソートすると、ファイルシステムの変更がリアルタイムで表示される[^3]

[^3]: https://www.voidtools.com/support/everything/using_everything/#find_recently_modified_files

---

## 5. サイズフィルター

```
size:>100mb           # 100MB より大きいファイル
size:1mb..500mb       # 1MB ～ 500MB のファイル
size:gigantic         # 128MB 超の巨大ファイル
size:empty            # 空のファイル
```

### サイズ定数

| 定数 | 範囲 |
|------|------|
| `empty` | 0 バイト |
| `tiny` | 0 ～ 10 KB |
| `small` | 10 ～ 100 KB |
| `medium` | 100 KB ～ 1 MB |
| `large` | 1 ～ 16 MB |
| `huge` | 16 ～ 128 MB |
| `gigantic` | 128 MB 以上 |

**実用例**: `size:gigantic !.iso` → 大容量ファイルのうち iso を除いて一覧表示し、ディスク整理に活用[^2]

---

## 6. 高度な関数

### 重複ファイル検索

```
dupe:             # 同名ファイルの重複を検索
sizedupe:         # サイズが同じファイルを検索
```

### フォルダ検索

```
empty:            # 空のフォルダを検索
child:report      # "report" というファイルを含むフォルダ
childcount:0      # 子要素が 0 個のフォルダ
depth:1           # ルート直下のみ
```

### 拡張子指定

```
ext:jpg;png;gif   # 複数拡張子をセミコロンで区切る
```

### 画像検索（メタデータ）

```
width:>1920           # 幅 1920px 以上の画像
dimension:3840x2160   # 4K 画像
orientation:landscape # 横向き画像
```

### ファイル属性

```
attrib:H          # 隠しファイル
attrib:R          # 読み取り専用ファイル
attrib:S          # システムファイル
```

---

## 7. キーボードショートカット

### 検索ボックスでのショートカット

| キー | 動作 |
|------|------|
| `Ctrl + A` | 全テキスト選択 |
| `Ctrl + Backspace` | 前の単語を削除 |
| `Alt + ↑ / ↓` | 検索履歴を表示 |
| `Enter` | 最も実行回数の多いファイルを開く |

### 結果リストでのショートカット

| キー | 動作 |
|------|------|
| `Enter` | 選択ファイルを開く |
| `Ctrl + Enter` | 選択ファイルのフォルダを開く |
| `Ctrl + Shift + C` | フルパスをクリップボードにコピー |
| `F2` | リネーム |
| `Alt + Enter` | プロパティを表示 |
| `Delete` | ゴミ箱に移動 |
| `Shift + Delete` | 完全削除 |
| `Ctrl + S` | 結果を CSV / TXT / EFU に出力 |

### ウィンドウ全体のショートカット

| キー | 動作 |
|------|------|
| `Ctrl + 1～9` | 各列でソート（例: `Ctrl+3` = サイズ順） |
| `Ctrl + R` | 正規表現のトグル |
| `Ctrl + I` | 大文字小文字区別のトグル |
| `Ctrl + B` | 単語単位マッチのトグル |
| `Ctrl + D` | 現在の検索をブックマーク |
| `Alt + P` | プレビューペインのトグル |
| `F11` | フルスクリーン切り替え |

[^4]: https://www.voidtools.com/support/everything/keyboard_shortcuts/

---

## 8. ホットキー（グローバル起動）

Everything をバックグラウンドで動かしておき、任意のキーコンビネーションでどこからでも呼び出せます[^4]：

**設定方法**:  
Tools → Options → Keyboard → Hotkey に任意のキーを設定

**推奨ホットキー**: `Win + Alt + E` や `Alt + Space` など

> **注意**: Win+F など Windows 標準ホットキーを上書きする場合は、レジストリの `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced` に `DisabledHotkeys` を追加して無効化が必要

---

## 9. 実行履歴（Run History）

Every time you open a file or folder from Everything, the run count is incremented. ファイルを開くたびに実行回数がカウントされ、検索後に `Enter` を押すと**最も頻繁に使うファイルが自動選択**されます[^5]。

```
runcount:>10       # 10回以上実行したファイル
runcount:1-5       # 1～5回実行
daterun:yesterday  # 昨日実行したファイル
```

**ホーム画面をランカウント降順にするとランチャー代わりに使える**：  
Tools → Options → Home → Sort: Run Count (Descending)

[^5]: https://www.voidtools.com/support/everything/run_history/

---

## 10. ブックマーク

よく使う検索条件（検索語・フィルター・ソート）をブックマーク保存できます。

- `Ctrl + D` で現在の検索をブックマーク
- `Ctrl + Shift + B` でブックマーク管理
- ブックマーク例:
  - `dm:today` → 「今日の更新ファイル」
  - `size:gigantic` → 「大容量ファイル一覧」
  - `ext:log dm:thisweek` → 「今週のログファイル」

---

## 11. HTTPサーバー機能（スマホ・他デバイスからアクセス）

Everything 内蔵の HTTP サーバーを起動すると、ブラウザから PC のファイルを検索・ダウンロードできます[^6]。

**起動方法**:  
Tools → Options → HTTP Server → Enable HTTP Server にチェック

**アクセス方法**:  
`http://コンピュータ名` または `http://localhost:80`

**API として利用（JSON）**:
```
http://localhost/?search=report&j=1&size_column=1&sort=size&ascending=0
```

主なパラメータ:

| パラメータ | 説明 |
|-----------|------|
| `s=` / `search=` | 検索クエリ |
| `j=1` | JSON 形式で返す |
| `c=100` | 最大件数 |
| `r=1` | 正規表現有効 |
| `sort=size` | ソート列 |

> セキュリティ注意: パスワード設定を推奨。ファイルダウンロードを禁止する場合は「Allow file download」をオフに。

[^6]: https://www.voidtools.com/support/everything/http/

---

## 12. コマンドラインインターフェース（es.exe）

`es.exe` を使うとコマンドプロンプト・PowerShell・スクリプトから Everything を活用できます[^7]。

**ダウンロード**: https://www.voidtools.com/downloads#cli  
**前提**: Everything が起動中であること

### 基本的な使い方

```powershell
# .log ファイルを検索
es.exe *.log

# 今週変更された .xlsx を CSV で出力
es.exe -size -dm -export-csv C:\output.csv "ext:xlsx dm:thisweek"

# 大容量ファイル TOP10 を表示
es.exe -sort size -sort-descending -n 10 size:huge

# 正規表現で検索
es.exe -r "report_20\d{2}\.pdf"

# JSON 出力してパイプライン処理
es.exe -csv "*.log dm:today" | ConvertFrom-Csv
```

### よく使うオプション

| オプション | 説明 |
|-----------|------|
| `-n <数>` | 最大件数制限 |
| `-s` | フルパスでソート |
| `-r <検索>` | 正規表現 |
| `-i` | 大文字小文字区別 |
| `-size` | サイズ列を表示 |
| `-dm` | 更新日列を表示 |
| `-csv` | CSV 形式で出力 |
| `-export-csv <ファイル>` | CSV ファイルに書き出し |
| `-sort size` | サイズでソート |
| `-sort-descending` | 降順ソート |

[^7]: https://www.voidtools.com/support/everything/command_line_interface/

---

## 13. 実践的なユースケース集

### ① 最近編集したファイルを素早く見つける

```
dm:today
dm:thisweek
```
→ 「あのファイルどこだっけ」問題を即解決

### ② ディスク容量の圧迫原因を特定

```
size:gigantic
size:>500mb !.iso
```
→ 大容量ファイルを洗い出し

### ③ 特定プロジェクトのファイルを横断検索

```
path: \my-project ext:py;js;ts
```
→ プロジェクトフォルダ内のソースコードのみ表示

### ④ 重複ファイル整理

```
dupe: pic:
```
→ 重複している画像ファイルを一覧表示

### ⑤ 空フォルダの掃除

```
empty: folder:
```

### ⑥ 最近作成された実行ファイルをチェック（セキュリティ）

```
exe: dc:today
```
→ 怪しい実行ファイルが今日作られていないか確認

### ⑦ 特定の音楽アルバムを検索

```
audio: album:Abbey Road
```

### ⑧ PowerShell でファイル一覧を取得してバッチ処理

```powershell
# 30日以上前に作成された一時ファイルを一覧化
es.exe -csv -dc -dm "ext:tmp;temp dc:lastmonth" | 
    ConvertFrom-Csv | 
    Select-Object Filename, @{N='Size';E={[long]$_.Size}} |
    Sort-Object Size -Descending
```

---

## 14. ファイルリスト（EFU）機能

CD/DVD/NAS/外付けドライブなどオフラインデバイスのファイルリストを作成し、Everything のインデックスに含められます。

- Tools → File List Editor で管理
- `Ctrl + S` で現在の結果を EFU（Everything File Update）形式でエクスポート
- NAS のマウントなしでも NAS 上のファイルを検索可能

---

## 15. 設定のカスタマイズTips

| 設定 | 場所 | 推奨設定 |
|------|------|----------|
| ホットキー | Tools → Options → Keyboard | `Win+Alt+E` など使いやすいキーに |
| 実行回数順ソート | Tools → Options → Home → Sort | Run Count (Descending) に変更でランチャー化 |
| 常駐 | Tools → Options → General | 「Start Everything on system startup」にチェック |
| フォルダ除外 | Tools → Options → Exclude | System32 など不要フォルダを除外して高速化 |
| HTTP サーバー | Tools → Options → HTTP Server | スマホからアクセスしたい場合に有効化 |

---

## Confidence Assessment

| 情報 | 確信度 | 備考 |
|------|--------|------|
| 基本検索構文 | ✅ 高 | voidtools 公式ドキュメントより |
| キーボードショートカット | ✅ 高 | 公式ドキュメントより |
| HTTP サーバー API | ✅ 高 | 公式ドキュメントより |
| es.exe コマンドライン | ✅ 高 | 公式ドキュメントより |
| ユースケース例 | 🔶 中 | 公式ドキュメント＋一般的な活用パターン |
| Everything 2.0 の新機能 | ❌ 未調査 | ベータ版の機能は本レポートに含まない |

---

## 参考リンク

- [Everything 公式サイト](https://www.voidtools.com/)
- [検索構文リファレンス](https://www.voidtools.com/support/everything/searching/)
- [キーボードショートカット一覧](https://www.voidtools.com/support/everything/keyboard_shortcuts/)
- [HTTP サーバー](https://www.voidtools.com/support/everything/http/)
- [コマンドラインインターフェース (es.exe)](https://www.voidtools.com/support/everything/command_line_interface/)
- [実行履歴](https://www.voidtools.com/support/everything/run_history/)

---

## Footnotes

[^1]: [Using Everything – voidtools](https://www.voidtools.com/support/everything/using_everything/)
[^2]: [Searching – voidtools](https://www.voidtools.com/support/everything/searching/)
[^3]: [Using Everything – Find recently modified files](https://www.voidtools.com/support/everything/using_everything/)
[^4]: [Keyboard Shortcuts – voidtools](https://www.voidtools.com/support/everything/keyboard_shortcuts/)
[^5]: [Run History – voidtools](https://www.voidtools.com/support/everything/run_history/)
[^6]: [HTTP Server – voidtools](https://www.voidtools.com/support/everything/http/)
[^7]: [Command Line Interface (es.exe) – voidtools](https://www.voidtools.com/support/everything/command_line_interface/)
