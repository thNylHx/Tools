#!/bin/bash

# === 配置参数 ===
## GitHub 相关
# GitHub 用户名
# 这是您在 GitHub 上的用户名。您需要将其替换为您自己的 GitHub 用户名。
NAME="GitHub 的用户名"

# GitHub 分配的临时邮箱前缀
# GitHub 会为每个账户分配一个临时的、不公开的邮箱前缀，以确保您的电子邮件地址不会公开。
# 这个邮箱通常是类似 `username+github@users.noreply.github.com` 的形式。您需要根据自己的 GitHub 账户设置填写该字段。
PREFIX="GitHub 分配的临时邮箱前缀"

# GitHub token
# 这是用于验证您的身份的 GitHub token。它是您通过 GitHub 的设置页面生成的个人访问令牌，用于进行 API 调用和仓库操作。
# 如果没有创建过 GitHub token，您可以在 GitHub 设置 > Developer settings > Personal access tokens 创建。
TOKEN="GitHub token"

# GitHub 仓库分支名
# 这个变量指定了要操作的 GitHub 仓库分支名。常见的分支名有 `main` 或 `master`。
# 如果您的仓库使用的是 `master` 作为主分支，可以修改此变量为 `master`。
BRANCH_NAME="main"

# GitHub 仓库 URL
# 这是 GitHub 仓库的克隆 URL。通过 GitHub 用户名和 token 动态生成的，方便在脚本中自动化认证。
# 格式为：`https://<用户名>:<token>@github.com/<用户名>/<仓库名>.git`，其中 `<仓库名>` 在此脚本中为 `Tools`。
GITHUB_URL="https://${NAME}:${TOKEN}@github.com/${NAME}/Tools.git"

## 本地相关
# 本地文件夹路径
# 这个变量指定了在本地存储克隆仓库的路径。请根据您的实际文件路径修改此值。
# 例如：`C:\Users\YourUsername\Documents\Tools` 或者 `D:\Tools`。
# 注意：路径分隔符使用的是 Windows 系统的反斜杠 `\`，但如果路径包含空格或其他特殊字符，请用引号将路径包裹起来。
FOLDERS="你电脑上的实际文件路径"

# === 配置 Git 用户信息 ===
# 设置 Git 用户名
# 这个命令配置 Git 全局使用的用户名。它会在您进行 Git 提交时作为作者信息显示。
# `${NAME}` 是前面定义的变量，它存储的是您的 GitHub 用户名。
git config --global user.name "${NAME}"

# 设置 Git 用户邮箱
# 这个命令配置 Git 全局使用的电子邮件地址。Git 提交时会将该邮箱作为作者信息附加到每次提交中。
# `${PREFIX}` 是前面定义的变量，它存储的是您的 GitHub 邮箱前缀。
# `${NAME}` 会与前面的 `${PREFIX}` 一起组成一个临时的 GitHub 隐私邮箱地址，确保您的实际邮箱不会暴露。
git config --global user.email "${PREFIX}+${NAME}@users.noreply.github.com"

# === 设置换行符自动转换行为 ===
# 检查操作系统类型
# `OSTYPE` 是一个环境变量，它存储了操作系统类型的字符串。
# 如果操作系统是 Windows，`OSTYPE` 会返回 'msys' 或 'win32'。
# 如果操作系统是类 Unix 系统（如 Linux 或 macOS），`OSTYPE` 将返回其他字符串（通常为 'linux-gnu' 或 'darwin'）。
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows 系统：启用换行符转换
    # 在 Windows 上，文本文件的换行符通常是 CRLF（回车 + 换行），而 Git 默认使用 LF（换行）作为换行符。
    # 设置 `core.autocrlf` 为 `true`，Git 会自动将 CRLF 转换为 LF，在提交时会转换为 LF。
    # 当您从仓库中拉取代码时，Git 会自动将 LF 转换为 CRLF（如果您在 Windows 上操作）。
    git config --global core.autocrlf true  # Windows 系统
else
    # Linux/macOS 系统：启用换行符转换
    # 在类 Unix 系统（如 Linux 和 macOS）中，换行符通常是 LF（换行）。
    # 设置 `core.autocrlf` 为 `input`，意味着 Git 只会在提交时将 CRLF 转换为 LF，但拉取时不做任何转换。
    # 这样可以确保在类 Unix 系统中，文件保持一致的 LF 换行符，不会将其转换为 CRLF。
    git config --global core.autocrlf input # Linux/macOS 系统
fi

# === 检查项目目录是否存在 ===
# 判断本地文件夹是否存在
# 如果目录 `$FOLDERS` 不存在，则执行克隆操作
if [ ! -d "$FOLDERS" ]; then
    # 如果文件夹不存在，输出提示并开始克隆远程仓库
    echo "$FOLDERS 不存在，开始克隆仓库"

    # 使用 `git clone` 命令克隆远程仓库到指定目录
    # `$GITHUB_URL` 是远程仓库的 URL，`$FOLDERS` 是目标本地路径
    git clone "$GITHUB_URL" "$FOLDERS"

    # 检查克隆是否成功
    # 再次检查目录 `$FOLDERS` 是否创建成功（即克隆是否成功）
    if [ ! -d "$FOLDERS" ]; then
        # 如果克隆失败，输出错误信息并退出脚本
        echo "克隆仓库失败，退出脚本"
        
        # 使用 `exit 1` 退出脚本，表示脚本执行失败。
        exit 1
    fi
    # 克隆成功后，输出提示信息
    echo "仓库已成功克隆到 $FOLDERS"
else
    # 如果目录已存在，则跳过克隆操作
    echo "$FOLDERS 目录已经存在，跳过克隆操作"
fi

# === 切换到仓库目录 ===
# 使用 `cd` 命令尝试进入 `$FOLDERS` 指定的目录。
cd "$FOLDERS" || { 
    # 如果 `cd` 命令失败（即无法进入目录），则执行 `{}` 内的代码块。
    # 输出错误信息，提示无法切换到指定目录。
    echo "无法切换到目录 $FOLDERS，退出脚本"

    # 使用 `exit 1` 退出脚本，表示脚本执行失败。
    exit 1
}

# === 检查并设置远程仓库地址 ===
# 使用 `git remote` 命令检查是否已经配置了远程仓库
# `git remote` 会列出当前仓库的远程仓库地址（如 origin）。
# `grep -q "origin"` 用来检查输出中是否包含 "origin" 字符串。
# 如果没有找到 "origin"，则返回 true，表示远程仓库未配置。
if ! git remote | grep -q "origin"; then
    # 如果没有配置 "origin"，则使用 `git remote add` 命令添加远程仓库
    # `git remote add origin "$GITHUB_URL"` 会将远程仓库地址 `$GITHUB_URL` 添加为 "origin"。
    git remote add origin "$GITHUB_URL"
else
    # 如果已经配置了 "origin" 远程仓库，则使用 `git remote set-url` 更新远程仓库地址
    # `git remote set-url origin "$GITHUB_URL"` 会将 "origin" 的远程仓库地址更新为 `$GITHUB_URL`。
    git remote set-url origin "$GITHUB_URL"
fi

# === 获取最新的远程仓库更新 ===
# 使用 `git fetch` 命令从远程仓库获取最新的提交信息。
# 但 `git fetch` 只会下载更新，不会自动合并到当前分支。
git fetch origin

# === 获取当前本地分支与远程分支的差异 ===
# `git rev-parse @` 获取当前本地分支的最新提交哈希值
LOCAL_COMMIT=$(git rev-parse @)
# `git rev-parse @{u}` 获取远程跟踪分支的最新提交哈希值
REMOTE_COMMIT=$(git rev-parse @{u})

# === 检查本地和远程是否有差异 ===
# 如果本地提交和远程提交不同，表示远程仓库有更新。
if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
    echo "检测到远程仓库有更新，准备拉取更新到本地"

    # 显示远程更新的提交内容
    # `git log --oneline "$LOCAL_COMMIT".."$REMOTE_COMMIT"` 显示本地提交和远程提交之间的差异
    echo "远程更新内容："
    git log --oneline "$LOCAL_COMMIT".."$REMOTE_COMMIT"

    # 使用 `git pull` 拉取远程更新并合并到本地分支
    # 拉取 `origin` 仓库中的 `main` 分支的更新
    git pull origin main  # 如果是其他分支，替换 `main` 为目标分支名
else
    echo "远程仓库没有更新，无需拉取"
fi

# === 检查是否有本地变化 ===
# `git status --porcelain` 返回简洁的状态输出，便于脚本处理
STATUS=$(git status --porcelain)
# 如果返回的状态不为空，表示有文件变更（包括新增、修改或删除）
if [ -n "$STATUS" ]; then
    echo "检测到本地文件有变更，准备同步到远程仓库"

    # 使用 `git add -A` 命令添加所有更改（新增、修改和删除）
    git add -A

    # 提交本地更改，提交消息为当前时间戳
    git commit -m "Update $(date +'%Y-%m-%d %H:%M:%S')"

    # 使用 `git push` 将本地更改推送到远程仓库
    git push origin main  # 如果是其他分支，替换 `main` 为目标分支名
    echo "同步成功"
else
    echo "本地文件没有变更，无需同步到远程仓库"
fi

exit 0