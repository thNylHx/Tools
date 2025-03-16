#!/bin/bash

#!name = GitHub 自动同步脚本   # 脚本名称，不参与执行
#!desc = 自动同步              # 脚本描述
#!date = 2025-03-12 17:30     # 脚本创建或修改日期
#!author = ChatGPT            # 脚本作者

sh_ver="0.0.1"   # 设置脚本版本
# 定义脚本版本号，用于记录脚本当前版本

###############################################
# 多账户配置，每个账户以分号分隔，格式如下：
# USERNAME;EMAIL_PREFIX;GITHUB_TOKEN;PROJECT_DIR
# 定义多个数组，分别存放 GitHub 用户名、邮箱前缀、本地项目目录
###############################################
# 以上注释说明了如何配置多账户，每个账户用分号分隔配置项

ACCOUNTS=(
    "xxxxxx;123456789;ghp_xxxxxx;你电脑上的实际路径"
    # 第1个账户：用户名、邮箱前缀、GitHub 访问令牌、项目本地路径
    "xxxxxx;123456789;ghp_xxxxxx;D:\GitHub\用户名\仓库名字"
    # 第2个账户：用户名、邮箱前缀、GitHub 访问令牌、项目本地路径
)

###############################################
# 同步函数：同步单个账户的仓库
###############################################
# 定义一个函数，用于处理单个账户的仓库同步逻辑

sync_repo() {
    local USERNAME="$1"
    # 定义局部变量 USERNAME，取函数第1个参数（GitHub 用户名）
    local EMAIL_PREFIX="$2"
    # 定义局部变量 EMAIL_PREFIX，取函数第2个参数（邮箱前缀）
    local GITHUB_TOKEN="$3"
    # 定义局部变量 GITHUB_TOKEN，取函数第3个参数（GitHub 访问令牌）
    local PROJECT_DIR="$4"
    # 定义局部变量 PROJECT_DIR，取函数第4个参数（项目本地目录）
    
    local REPO_URL="https://${USERNAME}:${GITHUB_TOKEN}@github.com/${USERNAME}/Tools.git"
    # 构造仓库 URL，采用包含令牌的格式以便实现自动认证

    echo "========================================"
    # 输出分隔线，便于区分不同账户的操作日志
    echo "🚀 当前执行账户：${USERNAME}"
    # 输出当前正在执行同步操作的账户名
    
    # 配置 Git 用户信息
    git config --global user.name "${USERNAME}"
    # 全局配置 Git 用户名为当前账户的用户名
    git config --global user.email "${EMAIL_PREFIX}+${USERNAME}@users.noreply.github.com"
    # 全局配置 Git 用户邮箱，邮箱格式为 EMAIL_PREFIX+USERNAME@users.noreply.github.com

    # 设置换行符自动转换行为
    # 如 Linux 系统下使用：
    git config --global core.autocrlf input
    # 配置 Git 在 Linux 系统下仅将 CRLF 转为 LF

    # 检查项目目录是否存在
    if [ ! -d "$PROJECT_DIR" ]; then
        # 如果指定的项目目录不存在，则执行克隆操作
        echo "📂 检查文件本地不存在，开始克隆仓库"
        git clone "${REPO_URL}" "${PROJECT_DIR}" || { echo "❌ 克隆失败"; return 1; }
        # 克隆远程仓库到本地目录，若失败则输出错误信息并返回退出
        echo "✅ 克隆成功，文件保存位置：${PROJECT_DIR}"
        # 输出克隆成功提示以及本地保存路径
    else
        echo "📂 本地文件本地已存在，跳过克隆操作"
        # 如果本地项目目录已存在，则跳过克隆操作
    fi

    # 进入项目目录
    echo "📂 进入执行目录：$PROJECT_DIR"
    # 输出提示，显示将要进入的项目目录
    cd "$PROJECT_DIR" || { echo "❌ 切换目录失败"; return 1; }
    # 切换当前工作目录到项目目录，若失败则输出错误信息并返回退出
    sleep 1s
    # 暂停 1 秒，等待目录切换稳定

    # 检查并设置远程仓库
    if ! git remote | grep -q "origin"; then
        # 如果当前仓库没有名为 origin 的远程仓库，则添加
        git remote add origin "${REPO_URL}"
        # 添加远程仓库 origin，使用构造的 REPO_URL
    else
        git remote set-url origin "${REPO_URL}"
        # 如果已存在，则更新 origin 的 URL 为 REPO_URL
    fi

    # 获取最新的远程仓库更新
    git fetch origin || { echo "Git fetch 失败"; return 1; }
    # 执行 git fetch 从远程获取最新更新，若失败则输出错误信息并返回退出

    # 获取本地最新提交ID
    LOCAL_COMMIT=$(git rev-parse @)
    # 通过 git rev-parse 获取当前分支最新提交的哈希值并赋值给 LOCAL_COMMIT
    # 获取远程 main 分支最新提交ID
    REMOTE_COMMIT=$(git rev-parse origin/main)
    # 获取远程 main 分支最新提交的哈希值并赋值给 REMOTE_COMMIT

    # 检查远程是否有更新
    echo "🔎 开始检测远程仓库是否有更新，请等待"
    # 输出提示，表示开始检测远程仓库更新
    sleep 3s
    # 暂停 3 秒，等待操作
    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        # 如果本地提交和远程提交不一致，则说明远程有更新
        echo "🔄 检测到远程仓库有更新，准备拉取并同步"
        # 输出提示，表示检测到远程有更新，准备同步
        # 如果有未提交的更改则先暂存
        if [ -n "$(git status --porcelain)" ]; then
            # 判断 git status 输出是否不为空，表示存在未提交的更改
            git stash -u
            # 将当前未提交的更改（包括未跟踪文件）暂存起来
        fi
        git pull --rebase origin main || { echo "Git pull 失败"; return 1; }
        # 使用 --rebase 方式拉取远程 main 分支更新，若失败则输出错误信息并返回退出
        if [ -n "$(git stash list)" ]; then
            # 如果暂存列表不为空，则有之前暂存的更改
            git stash pop
            # 恢复暂存的更改
        fi
        echo "✅ 已拉取并同步"
        # 输出提示，表示拉取并同步成功
    else
        echo "🔔 未检测到远程仓库有变更，无需拉取并同步"
        # 如果本地和远程提交一致，则输出提示，无需拉取更新
    fi

    # 检查本地是否有未提交的更改
    echo "🔎 开始检测本地仓库是否有变更，请等待"
    # 输出提示，表示开始检测本地仓库是否有变更
    sleep 3s
    # 暂停 3 秒，等待操作
    if [ -n "$(git status --porcelain)" ]; then
        # 判断 git status 输出是否不为空，表示存在未提交的本地更改
        echo "🔄 检测到本地仓库有变更，准备提交并同步"
        # 输出提示，表示检测到本地更改，准备提交
        git add -A
        # 将所有更改添加到暂存区
        git commit -m "Update $(date +'%Y-%m-%d %H:%M:%S')"
        # 提交更改，并以当前日期时间作为提交信息
        git push origin main || { echo "Git push 失败"; return 1; }
        # 将本次提交推送到远程 main 分支，若失败则输出错误信息并返回退出
        echo "✅ 已提交并同步"
        # 输出提示，表示提交并推送成功
    else
        echo "🔔 未检测到本地仓库有变更，无需提交并同步"
        # 如果没有本地更改，则输出提示，无需提交
    fi

    echo "✅ 恭喜你！账户 ${USERNAME} 同步成功"
    # 输出提示，表示当前账户的同步操作全部完成
    # 返回原目录
    cd - > /dev/null
    # 切换回之前的目录，并将命令输出隐藏
    echo "========================================"
    # 输出分隔线，结束当前账户的操作日志
    echo ""
    # 输出空行，增加可读性
    return 0
    # 同步函数正常结束，返回状态 0
}

###############################################
# 遍历所有账户，执行同步操作
###############################################
# 开始循环处理配置中的每个账户

for account in "${ACCOUNTS[@]}"; do
    # 遍历 ACCOUNTS 数组中的每个账户配置
    # 使用分号分隔各个配置项
    IFS=';' read -r USERNAME EMAIL_PREFIX GITHUB_TOKEN PROJECT_DIR <<< "$account"
    # 使用 IFS 分隔符将单个账户配置字符串分割为 4 个部分，分别赋值给变量
    sync_repo "$USERNAME" "$EMAIL_PREFIX" "$GITHUB_TOKEN" "$PROJECT_DIR"
    # 调用 sync_repo 函数，传入当前账户的配置参数进行同步操作
done

echo "========================================"
# 输出分隔线，表示所有账户的操作均已执行完毕

# 输出任务执行成功信息
echo "🎉 恭喜你！任务执行成功"  # 输出成功提示
# 输出任务执行成功的提示信息，表明整个脚本运行完毕

echo "========================================"
# 输出分隔线，增加可读性

exit 0
# 正常退出脚本，并返回状态码 0