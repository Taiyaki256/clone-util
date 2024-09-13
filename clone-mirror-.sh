#!/bin/bash

# 引数チェック
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <original-repo-url>"
  exit 1
fi

# オリジナルリポジトリのURLを取得
original_repo_url="$1"

# リポジトリ名を取得
repo_name=$(basename -s .git "$original_repo_url")

echo "repo_name: $repo_name"

# 自分のGitHubユーザー名を取得
gh_user=$(gh api user | jq -r .login)

echo "gh_user: $gh_user"

echo "Cloning $original_repo_url "

# リポジトリを --mirror でクローン
git clone --mirror "$original_repo_url"
if [ $? -ne 0 ]; then
  echo "Failed to clone repository."
  exit 1
fi

echo "Repository cloned successfully."

echo "Creating new repository on GitHub..."

# 自分のGitHubアカウントにプライベートリポジトリを作成
gh repo create "$gh_user/$repo_name" --private --confirm
if [ $? -ne 0 ]; then
  echo "Failed to create GitHub repository."
  exit 1
fi

echo "Repository created successfully."

# リポジトリのディレクトリに移動
cd "$repo_name.git" || exit

echo "Pushing to $gh_user/$repo_name..."

# 新しいリポジトリに --mirror でプッシュ
git push --mirror "https://github.com/$gh_user/$repo_name.git"
if [ $? -ne 0 ]; then
  echo "Failed to push to new repository."
  exit 1
fi

echo "Repository cloned and pushed to $gh_user/$repo_name successfully."
