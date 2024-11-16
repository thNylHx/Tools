#!/bin/bash

# 配置参数
NAME="GitHub 的用户名"
PREFIX="GitHub 分配的临时邮箱前缀"
TOKEN="GitHub token"
FOLDERS="D:\你电脑上的实际文件路径"
GITHUB_URL="https://${NAME}:${TOKEN}@github.com/${NAME}/Tools.git"

# 配置 Git 用户信息
git config --global user.name "${NAME}"
git config --global user.email "${PREFIX}+${NAME}@users.noreply.github.com"

# 设置换行符自动转换行为
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    git config --global core.autocrlf true  # Windows 系统
else
    git config --global core.autocrlf input # Linux/macOS 系统
fi

# 检查项目目录是否存在
if [ ! -d "$FOLDERS" ]; then
    echo "$FOLDERS 不存在，开始克隆仓库"

    # 克隆远程仓库
    git clone "$GITHUB_URL" "$FOLDERS"

    # 检查是否成功克隆仓库
    if [ ! -d "$FOLDERS" ]; then
        echo "克隆仓库失败，退出脚本"
        exit 1
    fi
    echo "仓库已成功克隆到 $FOLDERS"
else
    echo "$FOLDERS 目录已经存在，跳过克隆操作"
fi

# 切换到仓库目录
cd "$FOLDERS" || { echo "无法切换到目录 $FOLDERS，退出脚本"; exit 1; }

# 检查并设置远程仓库地址
if ! git remote | grep -q "origin"; then
    git remote add origin "$GITHUB_URL"
else
    git remote set-url origin "$GITHUB_URL"
fi

# 获取最新的远程仓库更新
git fetch origin

# 获取当前本地分支与远程分支的差异
LOCAL_COMMIT=$(git rev-parse @)
REMOTE_COMMIT=$(git rev-parse @{u})

# 检查本地和远程是否有差异
if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
    echo "检测到远程仓库有更新，准备克隆到本地文件"

    # 显示远程更新的提交内容
    echo "远程更新内容："
    git log --oneline "$LOCAL_COMMIT".."$REMOTE_COMMIT"

    # 拉取远程更新并合并到本地
    git pull origin main  # 如果是其他分支，替换 `main` 为目标分支名
else
    echo "远程仓库没有更新，无需克隆到本地文件"
fi

# 检查是否有本地变化
STATUS=$(git status --porcelain)
if [ -n "$STATUS" ]; then
    echo "检测到本地文件有变更，准备同步到远程仓库"

    # 添加所有更改（新增、修改和删除）
    git add -A

    # 提交本地文件更改
    git commit -m "Update $(date +'%Y-%m-%d %H:%M:%S')"

    # 推送所有变更到远程仓库
    git push origin main  # 如果是其他分支，替换 `main` 为目标分支名
    echo "同步成功"
else
    echo "本地文件没有变更，无需同步到远程仓库"
fi

exit 0