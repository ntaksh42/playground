<#
.SYNOPSIS
    ディレクトリ内の全Gitリポジトリを一括更新するスクリプト

.DESCRIPTION
    指定されたディレクトリ内にあるすべてのGitリポジトリを検索し、
    各リポジトリを最新の状態に更新します。
    リモートブランチが削除されている場合は、デフォルトブランチに切り替えます。

.PARAMETER Path
    検索対象のルートディレクトリパス。省略時はカレントディレクトリを使用します。

.PARAMETER Depth
    サブディレクトリを検索する深さ。デフォルトは1（直下のディレクトリのみ）。

.EXAMPLE
    .\Update-AllGitRepos.ps1
    カレントディレクトリ直下のGitリポジトリを更新

.EXAMPLE
    .\Update-AllGitRepos.ps1 -Path "C:\Projects" -Depth 2
    C:\Projectsの2階層下までのGitリポジトリを更新
#>

param(
    [string]$Path = ".",
    [int]$Depth = 1
)

# カラー表示用の関数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Gitリポジトリを更新する関数
function Update-GitRepository {
    param(
        [string]$RepoPath
    )

    $repoName = Split-Path $RepoPath -Leaf
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "リポジトリ: $repoName" "Cyan"
    Write-ColorOutput "パス: $RepoPath" "Gray"
    Write-ColorOutput "========================================" "Cyan"

    Push-Location $RepoPath

    try {
        # リモート情報を取得
        Write-ColorOutput "リモート情報を取得中..." "Yellow"
        $fetchResult = git fetch --all --prune 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "警告: フェッチに失敗しました - $fetchResult" "Yellow"
        }

        # 現在のブランチを取得
        $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
        if ([string]::IsNullOrEmpty($currentBranch)) {
            Write-ColorOutput "エラー: ブランチ情報を取得できませんでした" "Red"
            return
        }

        Write-ColorOutput "現在のブランチ: $currentBranch" "White"

        # デフォルトブランチを取得（origin/HEADから）
        $defaultBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null
        if ($defaultBranch) {
            $defaultBranch = $defaultBranch -replace 'refs/remotes/origin/', ''
        } else {
            # origin/HEADが設定されていない場合は、mainまたはmasterを試す
            $remoteBranches = git branch -r 2>$null
            if ($remoteBranches -match 'origin/main') {
                $defaultBranch = 'main'
            } elseif ($remoteBranches -match 'origin/master') {
                $defaultBranch = 'master'
            } else {
                # 最初のリモートブランチを使用
                $firstBranch = ($remoteBranches | Select-Object -First 1) -replace '^\s*origin/', '' -replace '\s.*$', ''
                $defaultBranch = $firstBranch
                Write-ColorOutput "警告: デフォルトブランチを特定できないため、$defaultBranch を使用します" "Yellow"
            }
        }

        # 現在のブランチがリモートに存在するか確認
        $remoteBranchExists = git ls-remote --heads origin $currentBranch 2>$null

        if ([string]::IsNullOrEmpty($remoteBranchExists) -and $currentBranch -ne "HEAD") {
            Write-ColorOutput "警告: ブランチ '$currentBranch' はリモートに存在しません" "Yellow"
            Write-ColorOutput "デフォルトブランチ '$defaultBranch' に切り替えます..." "Yellow"

            # 未コミットの変更があるか確認
            $status = git status --porcelain
            if (![string]::IsNullOrEmpty($status)) {
                Write-ColorOutput "警告: 未コミットの変更があります。スタッシュします..." "Yellow"
                git stash save "Auto-stash before switching to $defaultBranch" 2>&1 | Out-Null
            }

            # デフォルトブランチに切り替え
            git checkout $defaultBranch 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ ブランチを '$defaultBranch' に切り替えました" "Green"
                $currentBranch = $defaultBranch
            } else {
                Write-ColorOutput "エラー: ブランチの切り替えに失敗しました" "Red"
                return
            }
        }

        # プルを実行
        Write-ColorOutput "最新の変更を取得中..." "Yellow"
        $pullResult = git pull 2>&1

        if ($LASTEXITCODE -eq 0) {
            if ($pullResult -match "Already up to date" -or $pullResult -match "最新") {
                Write-ColorOutput "✓ すでに最新です" "Green"
            } else {
                Write-ColorOutput "✓ 更新完了" "Green"
                Write-ColorOutput $pullResult "Gray"
            }
        } else {
            Write-ColorOutput "エラー: プルに失敗しました" "Red"
            Write-ColorOutput $pullResult "Red"
        }

    } catch {
        Write-ColorOutput "エラー: $_" "Red"
    } finally {
        Pop-Location
    }
}

# メイン処理
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Git リポジトリ一括更新スクリプト" "Cyan"
Write-ColorOutput "========================================" "Cyan"

# パスを絶対パスに変換
$absolutePath = Resolve-Path $Path -ErrorAction SilentlyContinue
if (-not $absolutePath) {
    Write-ColorOutput "エラー: パス '$Path' が見つかりません" "Red"
    exit 1
}

Write-ColorOutput "検索パス: $absolutePath" "White"
Write-ColorOutput "検索深度: $Depth" "White"

# Gitリポジトリを検索
$repos = @()
$searchPath = $absolutePath.Path

# 深度に応じてサブディレクトリを検索
for ($i = 0; $i -le $Depth; $i++) {
    $pattern = "\*" * ($i + 1)
    $gitDirs = Get-ChildItem -Path $searchPath -Filter ".git" -Directory -Recurse -Depth $i -ErrorAction SilentlyContinue
    foreach ($gitDir in $gitDirs) {
        $repoPath = $gitDir.Parent.FullName
        if ($repos -notcontains $repoPath) {
            $repos += $repoPath
        }
    }
}

if ($repos.Count -eq 0) {
    Write-ColorOutput "`n警告: Gitリポジトリが見つかりませんでした" "Yellow"
    exit 0
}

Write-ColorOutput "`n見つかったリポジトリ数: $($repos.Count)" "Green"

# 各リポジトリを更新
$successCount = 0
$failCount = 0

foreach ($repo in $repos) {
    try {
        Update-GitRepository -RepoPath $repo
        $successCount++
    } catch {
        Write-ColorOutput "エラー: $repo の更新に失敗しました - $_" "Red"
        $failCount++
    }
}

# サマリー表示
Write-ColorOutput "`n========================================" "Cyan"
Write-ColorOutput "更新完了" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "成功: $successCount" "Green"
if ($failCount -gt 0) {
    Write-ColorOutput "失敗: $failCount" "Red"
}
Write-ColorOutput "`n処理が完了しました。" "White"
