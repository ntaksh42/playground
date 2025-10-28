#!/usr/bin/env python3
"""
指定したディレクトリ配下のすべてのGitリポジトリを最新にするツール

使用方法:
    python update_all_repos.py <ディレクトリパス>
    python update_all_repos.py .  # カレントディレクトリ配下
    python update_all_repos.py C:\Projects  # Windowsドライブ配下
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import List, Tuple


class Colors:
    """ターミナル出力用のカラーコード"""
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def find_git_repositories(root_path: Path) -> List[Path]:
    """
    指定されたパス配下のすべてのGitリポジトリを検索

    Args:
        root_path: 検索を開始するルートパス

    Returns:
        Gitリポジトリのパスのリスト
    """
    repos = []

    print(f"{Colors.OKCYAN}Gitリポジトリを検索中...{Colors.ENDC}")

    for dirpath, dirnames, _ in os.walk(root_path):
        # .gitディレクトリが含まれているか確認
        if '.git' in dirnames:
            repos.append(Path(dirpath))
            # サブディレクトリの検索をスキップ（ネストされたリポジトリを避ける）
            dirnames.clear()

    return repos


def get_repo_status(repo_path: Path) -> Tuple[str, str, str]:
    """
    リポジトリの現在の状態を取得

    Args:
        repo_path: リポジトリのパス

    Returns:
        (ブランチ名, リモート名, ステータス)
    """
    try:
        # 現在のブランチを取得
        branch = subprocess.check_output(
            ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
            cwd=repo_path,
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()

        # リモートの状態を取得
        remote_info = subprocess.check_output(
            ['git', 'remote', '-v'],
            cwd=repo_path,
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()

        remote = remote_info.split()[0] if remote_info else 'N/A'

        # ステータスを取得
        status = subprocess.check_output(
            ['git', 'status', '--short'],
            cwd=repo_path,
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()

        return branch, remote, status

    except subprocess.CalledProcessError:
        return 'unknown', 'unknown', 'error'


def update_repository(repo_path: Path) -> Tuple[bool, str]:
    """
    リポジトリを更新（git pull）

    Args:
        repo_path: リポジトリのパス

    Returns:
        (成功/失敗, 出力メッセージ)
    """
    try:
        # まずgit fetchを実行
        subprocess.run(
            ['git', 'fetch'],
            cwd=repo_path,
            check=True,
            capture_output=True,
            text=True
        )

        # git pullを実行
        result = subprocess.run(
            ['git', 'pull'],
            cwd=repo_path,
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode == 0:
            output = result.stdout.strip()
            if 'Already up to date' in output or 'Already up-to-date' in output:
                return True, '既に最新です'
            else:
                return True, output
        else:
            return False, result.stderr.strip()

    except subprocess.TimeoutExpired:
        return False, 'タイムアウト（60秒）'
    except subprocess.CalledProcessError as e:
        return False, str(e)
    except Exception as e:
        return False, f'エラー: {str(e)}'


def main():
    """メイン処理"""

    # 引数チェック
    if len(sys.argv) < 2:
        print(f"{Colors.WARNING}使用方法: python {sys.argv[0]} <ディレクトリパス>{Colors.ENDC}")
        print(f"例: python {sys.argv[0]} .")
        print(f"例: python {sys.argv[0]} C:\\Projects")
        sys.exit(1)

    root_path = Path(sys.argv[1]).resolve()

    # パスの存在確認
    if not root_path.exists():
        print(f"{Colors.FAIL}エラー: 指定されたパスが存在しません: {root_path}{Colors.ENDC}")
        sys.exit(1)

    if not root_path.is_dir():
        print(f"{Colors.FAIL}エラー: 指定されたパスはディレクトリではありません: {root_path}{Colors.ENDC}")
        sys.exit(1)

    print(f"\n{Colors.BOLD}{Colors.HEADER}=== Gitリポジトリ一括更新ツール ==={Colors.ENDC}")
    print(f"{Colors.BOLD}検索パス:{Colors.ENDC} {root_path}\n")

    # リポジトリを検索
    repos = find_git_repositories(root_path)

    if not repos:
        print(f"{Colors.WARNING}Gitリポジトリが見つかりませんでした。{Colors.ENDC}")
        sys.exit(0)

    print(f"{Colors.OKGREEN}✓ {len(repos)}個のリポジトリを発見しました{Colors.ENDC}\n")

    # 各リポジトリを更新
    success_count = 0
    fail_count = 0
    skip_count = 0

    for i, repo in enumerate(repos, 1):
        print(f"{Colors.BOLD}[{i}/{len(repos)}] {repo.name}{Colors.ENDC}")
        print(f"    パス: {repo}")

        # リポジトリの状態を取得
        branch, remote, status = get_repo_status(repo)
        print(f"    ブランチ: {branch} | リモート: {remote}")

        # 未コミットの変更がある場合は警告
        if status:
            print(f"    {Colors.WARNING}⚠ 未コミットの変更があります - スキップします{Colors.ENDC}")
            skip_count += 1
            print()
            continue

        # リポジトリを更新
        print(f"    {Colors.OKCYAN}更新中...{Colors.ENDC}", end='', flush=True)
        success, message = update_repository(repo)

        if success:
            print(f"\r    {Colors.OKGREEN}✓ {message}{Colors.ENDC}")
            success_count += 1
        else:
            print(f"\r    {Colors.FAIL}✗ 失敗: {message}{Colors.ENDC}")
            fail_count += 1

        print()

    # 結果サマリー
    print(f"{Colors.BOLD}{Colors.HEADER}=== 更新結果 ==={Colors.ENDC}")
    print(f"{Colors.OKGREEN}成功: {success_count}{Colors.ENDC}")

    if skip_count > 0:
        print(f"{Colors.WARNING}スキップ: {skip_count}{Colors.ENDC}")

    if fail_count > 0:
        print(f"{Colors.FAIL}失敗: {fail_count}{Colors.ENDC}")

    print(f"合計: {len(repos)}")

    # 終了コード
    sys.exit(0 if fail_count == 0 else 1)


if __name__ == '__main__':
    main()
