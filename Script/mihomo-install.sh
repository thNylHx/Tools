#!/bin/bash
#!name = mihomo 一键脚本
#!desc = 支持，安装、更新、卸载等
#!date = 2024-08-17 15:30
#!author = thNylHx ChatGPT

set -e -o pipefail

# 颜色代码
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"

# 脚本版本
sh_ver="1.1.5"

# 全局变量
FILE="/root/mihomo/mihomo"
VERSION_FILE="/root/mihomo/version.txt"
SYSCTL_CONF="/etc/sysctl.conf"

clear
echo -e "================================="
echo -e "${Green_font_prefix}欢迎使用 mihomo 一键脚本${Font_color_suffix}"
echo -e "${Green_font_prefix}作者：${Font_color_suffix}${Red_font_prefix}thNylHx${Font_color_suffix}"
echo -e "${Green_font_prefix}请保证科学上网已经开启${Font_color_suffix}"
echo -e "${Green_font_prefix}安装过程中可以按 ctrl+c 强制退出${Font_color_suffix}"
echo -e "================================="

# 检查 mihomo 服务状态
check_status() {
    if pgrep -x "mihomo" > /dev/null; then
        status="running"
    else
        status="stopped"
    fi
}

# 获取当前安装版本
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "未安装"
    fi
}

# 显示当前脚本和服务状态
Show_Status() {
    if [ ! -f "$FILE" ]; then
        status="${Red_font_prefix}未安装${Font_color_suffix}"
    else
        check_status
        if [ "$status" == "running" ]; then
            status="${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}运行中${Font_color_suffix}"
        else
            status="${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未运行${Font_color_suffix}"
        fi
    fi

    echo -e "版本： ${Green_font_prefix}${sh_ver}${Font_color_suffix}"
    echo -e "状态： ${status}"
}

# 检查和设置 IP 转发参数
check_ip_forward() {
    # 要检查的设置
    local IPV4_FORWARD="net.ipv4.ip_forward = 1"

    # 检查是否已存在 net.ipv4.ip_forward = 1
    if grep -q "^${IPV4_FORWARD}$" "$SYSCTL_CONF"; then
        # 不执行 sysctl -p，因为设置已经存在
        return
    fi

    # 如果设置不存在，则添加并执行 sysctl -p
    echo "$IPV4_FORWARD" >> "$SYSCTL_CONF"
    # 立即生效
    sysctl -p
    echo -e "${Green_font_prefix}IP 转发开启成功。${Font_color_suffix}"
}

# 获取 CPU 架构
Get_the_schema(){
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='amd64';;
        'x86' | 'i686' | 'i386')     ARCH='386';;
        'aarch64' | 'arm64') ARCH='arm64';;
        'armv7l')   ARCH='armv7';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
    esac
}

# 检查是否已安装 mihomo
Check_install(){
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}mihomo 未安装${Font_color_suffix}"
        exit 1
    fi
}

# 安装 mihomo
Install() {
    # 检查是否安装 mihomo 
    if [ -f "$FILE" ]; then
        echo -e "${Green_font_prefix}mihomo 已经安装${Font_color_suffix}"
        exit 0
    fi
    echo -e "${Green_font_prefix}开始安装 mihomo${Font_color_suffix}"
    mkdir -p /root/mihomo && cd /root/mihomo || { echo -e "${Red_font_prefix}创建或进入 /root/mihomo 目录失败${Font_color_suffix}"; exit 1; }
    # 获取架构
    Get_the_schema
    echo -e "${Green_font_prefix}获取到当前设备架构: ${ARCH_RAW}${Font_color_suffix}"
    # 获取最新版本信息
    VERSION=$(curl -sSL "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt" || { echo -e "${Red_font_prefix}获取版本信息失败${Font_color_suffix}"; exit 1; })
    # 构建下载文件的名称# 根据系统架构（ARCH）和获取到的版本号（VERSION），生成目标文件的名称
    FILENAME="mihomo-linux-${ARCH}-${VERSION}.gz"
    # 输出获取到的最新版本信息
    echo -e "${Green_font_prefix}获取到的最新版本: ${VERSION}${Font_color_suffix}"
    # 构造文件名
    case "$ARCH" in
        'arm64' | 'armv7' | 's390x' | '386') FILENAME="mihomo-linux-${ARCH}-${VERSION}.gz";;
        'amd64') FILENAME="mihomo-linux-${ARCH}-compatible-${VERSION}.gz";;
        *)       echo -e "${Red_font_prefix}不支持的架构: ${ARCH}${Font_color_suffix}"; exit 1;;
    esac
    # 开始下载
    echo -e "${Green_font_prefix}开始下载 ${FILENAME}${Font_color_suffix}"
    wget -t 3 -T 30 "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${FILENAME}" -O "${FILENAME}" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }
    # 
    if [ -f "$FILENAME" ]; then
        echo -e "${Green_font_prefix}${FILENAME} 下载完成, 开始部署${Font_color_suffix}"
        # 解压 
        gunzip "$FILENAME" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
        # 根据架构重命名 mihomo 文件
        if [ -f "mihomo-linux-${ARCH}-${VERSION}" ]; then
            mv "mihomo-linux-${ARCH}-${VERSION}" mihomo
        elif [ -f "mihomo-linux-${ARCH}-compatible-${VERSION}" ]; then
            mv "mihomo-linux-${ARCH}-compatible-${VERSION}" mihomo
        else
            echo -e "${Red_font_prefix}找不到解压后的文件${Font_color_suffix}"
            exit 1
        fi
        # 授权
        chmod 777 mihomo
        # 保存版本信息
        echo "$VERSION" > "$VERSION_FILE"
        echo -e "${Green_font_prefix}mihomo 安装成功${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}下载的文件不存在${Font_color_suffix}"
        exit 1
    fi
    # 下载 UI
    git clone https://github.com/metacubex/metacubexd.git -b gh-pages /root/mihomo/ui
    # 系统配置文件
    wget -O /etc/systemd/system/mihomo.service https://raw.githubusercontent.com/thNylHx/Tools/main/Script/mihomo.service && chmod 777 /etc/systemd/system/mihomo.service
    echo -e "${Green_font_prefix}mihomo 安装完成，开始配置 mihomo${Font_color_suffix}"
    # 开始配置 config 文件
    Configure
    Main
}

# 更新 mihomo
Update() {
    Check_install
    echo -e "${Green_font_prefix}开始检查是否有更新${Font_color_suffix}"
    cd /root/mihomo
    # 获取当前版本
    CURRENT_VERSION=$(cat "$VERSION_FILE")
    # 获取最新版本
    LATEST_VERSION=$(curl -sSL "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt" || { echo -e "${Red_font_prefix}获取版本信息失败${Font_color_suffix}"; exit 1; })
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo -e "当前版本: ${Green_font_prefix}${CURRENT_VERSION}${Font_color_suffix}"
        echo -e "最新版本: ${Green_font_prefix}${LATEST_VERSION}${Font_color_suffix}"
        echo -e "当前已是最新版本，无需更新 ！"
        Main
    fi
    echo -e "当前版本: ${Green_font_prefix}${CURRENT_VERSION}${Font_color_suffix}"
    echo -e "最新版本: ${Green_font_prefix}${LATEST_VERSION}${Font_color_suffix}"
    read -p "是否升级到最新版本？(y/n): " confirm
    case $confirm in
        [Yy]* )
            echo -e "${Green_font_prefix}开始更新 mihomo${Font_color_suffix}"
            # 构造文件名和下载链接
            Get_the_schema
            echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"
            DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${FILENAME}"
            echo -e "${Green_font_prefix}开始下载最新版本 ${FILENAME}...${Font_color_suffix}"
            wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }
            echo -e "${Green_font_prefix}${FILENAME} 下载完成，开始更新${Font_color_suffix}"
            gunzip "$FILENAME" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
            # 文件移动与重命名
            if [ -f "mihomo-linux-${ARCH}-${LATEST_VERSION}" ]; then
                mv "mihomo-linux-${ARCH}-${LATEST_VERSION}" mihomo
            elif [ -f "mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}" ]; then
                mv "mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}" mihomo
            else
                echo -e "${Red_font_prefix}找不到下载后的文件${Font_color_suffix}"
                exit 1
            fi
            # 授权
            chmod 777 mihomo
            # 更新版本信息
            echo "$LATEST_VERSION" > "$VERSION_FILE"
            # 重新加载 systemd
            systemctl daemon-reload
            # 重启 mihomo 服务
            systemctl restart mihomo
            echo -e "更新完成，当前版本已更新为 ${Green_font_prefix}v${LATEST_VERSION}${Font_color_suffix}"
            # 检查并显示服务状态
            if systemctl is-active --quiet mihomo; then
                echo -e "当前状态：${Green_font_prefix}运行中${Font_color_suffix}"
            else
                echo -e "当前状态：${Green_font_prefix}未运行${Font_color_suffix}"
                exit 1
            fi
            exit 0
            ;;
        [Nn]* )
            echo -e "${Red_font_prefix}更新已取消。${Font_color_suffix}"
            ;;
        * )
            echo -e "${Red_font_prefix}无效的输入。${Font_color_suffix}"
            exit 1
            ;;
    esac
    Main
}

# 配置 mihomo
Configure() {
    echo -e "${Green_font_prefix}配置 mihomo...${Font_color_suffix}"
    # 获取用户输入机场数量
    read -p "是否有多个机场？目前只支持2个机场连接。(y/n): " multiple_airports
    if [[ "$multiple_airports" == "y" ]]; then
        # 配置多个机场
        read -p "请输入第一个机场的订阅连接: " airport_url1
        read -p "请输入第一个机场的名称: " airport_name1
        read -p "请输入第二个机场的订阅连接: " airport_url2
        read -p "请输入第二个机场的名称: " airport_name2
        # 下载 YAML 文件
        wget -O /root/mihomo/config.yaml https://raw.githubusercontent.com/thNylHx/Tools/main/Meta/mihomo-two.yaml
        # 使用 sed 替换 YAML 文件中的占位符
        sed -i "s#机场订阅连接1#$airport_url1#" /root/mihomo/config.yaml
        sed -i "s#\[机场名称1\]#$airport_name1#" /root/mihomo/config.yaml
        sed -i "s#机场订阅连接2#$airport_url2#" /root/mihomo/config.yaml
        sed -i "s#\[机场名称2\]#$airport_name2#" /root/mihomo/config.yaml
    else
        # 配置单个机场
        read -p "请输入机场的订阅连接: " airport_url
        read -p "请输入机场的名称: " airport_name
        # 下载 YAML 文件
        wget -O /root/mihomo/config.yaml https://raw.githubusercontent.com/thNylHx/Tools/main/Meta/mihomo-one.yaml
        # 使用 sed 替换 YAML 文件中的占位符
        sed -i "s#机场订阅连接#$airport_url#" /root/mihomo/config.yaml
        sed -i "s#\[机场名称\]#$airport_name#" /root/mihomo/config.yaml
    fi
    echo -e "${Green_font_prefix}mihomo 配置完成，正在启动中...${Font_color_suffix}"
    # 启动命令
    systemctl daemon-reload
    systemctl enable mihomo
    systemctl start mihomo
    systemctl status mihomo
    # 检查服务状态
    check_status
    # 返回主菜单
    Main
}

# 修改 mihomo 配置
Modify_Configuration() {
    # 检查是否安装 mihomo
    Check_install
    echo -e "${Green_font_prefix} mihomo 配置修改${Font_color_suffix}"
    Configure
    Main
}

# 启动 mihomo
Start() {
    # 检查是否安装 mihomo
    Check_install
    if systemctl is-active --quiet mihomo; then
        echo -e "${Green_font_prefix}mihomo 已经在运行中${Font_color_suffix}"
        exit 0
    fi
    echo -e "${Green_font_prefix}mihomo 启动中${Font_color_suffix}"
    # 尝试启用并启动服务
    if systemctl enable mihomo && systemctl start mihomo; then
        echo -e "${Green_font_prefix}mihomo 启动成功${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}mihomo 启动失败${Font_color_suffix}"
        exit 1
    fi
    Main
}

# 停止 mihomo
Stop() {
    # 检查是否安装 mihomo
    Check_install
    if ! systemctl is-active --quiet mihomo; then
        echo -e "${Green_font_prefix}mihomo 已经停止${Font_color_suffix}"
        exit 0
    fi
    echo -e "${Green_font_prefix}mihomo 停止中${Font_color_suffix}"
    # 尝试停止服务
    if systemctl stop mihomo; then
        echo -e "${Green_font_prefix}mihomo 成功停止${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}mihomo 停止失败${Font_color_suffix}"
        exit 1
    fi
    Main
}

# 卸载 mihomo
Uninstall() {
    # 检查是否安装 mihomo
    Check_install
    echo -e "${Green_font_prefix}mihomo 开始卸载${Font_color_suffix}"
    # 停止并禁用服务，如果失败则忽略错误
    systemctl stop mihomo || true
    systemctl disable mihomo || true
    # 删除服务文件和安装目录
    rm -f "$FILE"
    rm -f /etc/systemd/system/mihomo.service
    rm -rf /root/mihomo
    # 重新加载 systemd 守护程序
    systemctl daemon-reload
    # 检查卸载是否成功
    if [ ! -f "$FILE" ] && [ ! -d "/root/mihomo" ]; then
        echo -e "${Green_font_prefix}mihomo 卸载完成${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}卸载过程中出现问题，请手动检查${Font_color_suffix}"
    fi
    # 删除文件和目录
    if rm -f "$FILE" && rm -rf "$INSTALL_DIR"; then
        echo -e "${Green_font_prefix}mihomo 成功卸载${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}mihomo 卸载过程中发生错误${Font_color_suffix}"
        exit 1
    fi
    Main
}

# 重启 mihomo
Restart() {
    # 检查是否安装 mihomo
    Check_install
    echo -e "${Green_font_prefix}mihomo 准备重启${Font_color_suffix}"
    # 重启服务
    if systemctl restart mihomo; then
        echo -e "${Green_font_prefix}mihomo 重启中${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}mihomo 重启失败${Font_color_suffix}"
        exit 1
    fi
    echo -e "${Green_font_prefix}mihomo 重启完成${Font_color_suffix}"
    # 显示服务状态
    if [ "$status" == "running" ]; then
        echo -e "${Green_font_prefix}当前状态：运行中${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}当前状态：未运行${Font_color_suffix}"
    fi
    Main
}

# 检查更新脚本
Update_Shell() {
    # 获取当前版本
    echo -e "当前版本为 ${sh_ver}，开始检测最新版本..."
    # 获取最新版本号
    sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/thNylHx/Tools/main/Script/mihomo-install.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    if [ "$sh_ver" == "$sh_new_ver" ]; then
        echo -e "当前版本: ${Green_font_prefix}${sh_ver}${Font_color_suffix}"
        echo -e "最新版本: ${Green_font_prefix}${sh_new_ver}${Font_color_suffix}"
        echo -e "${Green_font_prefix}当前已是最新版本，无需更新！${Font_color_suffix}"
        Main
    fi
    echo -e "当前版本: ${Green_font_prefix}${sh_ver}${Font_color_suffix}"
    echo -e "最新版本: ${Green_font_prefix}${sh_new_ver}${Font_color_suffix}"
    # 开始更新
    read -p "是否升级到最新版本？(y/n): " confirm
    case $confirm in
        [Yy]* )
            echo -e "${Green_font_prefix}开始更新${Font_color_suffix}"
            wget -O mihomo-install.sh --no-check-certificate https://raw.githubusercontent.com/thNylHx/Tools/main/Script/mihomo-install.sh
            chmod +x mihomo-install.sh
            echo -e "更新完成，当前版本已更新为 ${Green_font_prefix}v${sh_new_ver}${Font_color_suffix}"
            echo -e "3 秒后执行新脚本..."
            sleep 3s
            bash mihomo-install.sh
            ;;
        [Nn]* )
            echo -e "${Red_font_prefix}更新已取消。${Font_color_suffix}"
            Main
            ;;
        * )
            echo -e "${Red_font_prefix}无效的输入。${Font_color_suffix}"
            exit 1
            ;;
    esac
}

# 主菜单
# 函数定义在这里
Main() {
    Show_Status
    echo -e "================================="
    echo -e "${Green_font_prefix}1${Font_color_suffix}、 安装 mihomo"
    echo -e "${Green_font_prefix}2${Font_color_suffix}、 更新 mihomo"
    echo -e "${Green_font_prefix}3${Font_color_suffix}、 配置 mihomo"
    echo -e "${Green_font_prefix}4${Font_color_suffix}、 卸载 mihomo"
    echo -e "${Green_font_prefix}5${Font_color_suffix}、 启动 mihomo"
    echo -e "${Green_font_prefix}6${Font_color_suffix}、 停止 mihomo"
    echo -e "${Green_font_prefix}7${Font_color_suffix}、 重启 mihomo"
    echo -e "${Green_font_prefix}8${Font_color_suffix}、 更新脚本"
    echo -e "${Green_font_prefix}0${Font_color_suffix}、 退出脚本"
    echo -e "================================="
    read -p "请输入选项[0-8]: " num
    case "$num" in
        1) check_ip_forward; Install ;;
        2) Update ;;
        3) Modify_Configuration ;;
        4) Uninstall ;;
        5) Start ;;
        6) Stop ;;
        7) Restart ;;
        8) Update_Shell ;;
        0) exit 0 ;;
        *) echo -e "${Red_font_prefix}无效选项，请重新选择${Font_color_suffix}" ;;
    esac
}
# 调用主菜单函数
Main
