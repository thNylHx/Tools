#!/bin/bash
#!name = trojan 一键脚本 Beta
#!desc = 支持，安装、更新、卸载等
#!date = 2024-08-24 10:20
#!author = thNylHx ChatGPT

set -e -o pipefail

# 定义颜色代码
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"

# 定义脚本版本
sh_ver="1.1.9"

# 定义全局变量
FOLDERS="/root/trojan"
ACME_FILE="/root/.acme.sh"
FILE="/root/trojan/trojan-go"
SSL_FILE="/root/trojan/ssl"
CONFIG_FILE="/root/trojan/config.json"
VERSION_FILE="/root/trojan/version.txt"
SYSTEM_FILE="/etc/systemd/system/trojan-go.service"

# 返回主菜单
Start_Main() {
    echo && echo -n -e "${Red_font_prefix}* 按回车返回主菜单 *${Font_color_suffix}" && read temp
    Main
}

# 检查是否已安装
Check_install(){
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}trojan 未安装${Font_color_suffix}"
        Start_Main
    fi
}

# 检查服务状态
Check_status() {
    if pgrep -x "trojan-go" > /dev/null; then
        status="running"
    else
        status="stopped"
    fi
}

# 获取当前安装版本
Get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "trojan 未安装"
    fi
}

# 显示当前脚本、是否设置开机自启和服务状态
Show_Status() {
    if [ ! -f "$FILE" ]; then
        status="${Red_font_prefix}未安装${Font_color_suffix}"
        run_status="${Red_font_prefix}未运行${Font_color_suffix}"
        auto_start="${Red_font_prefix}未设置${Font_color_suffix}"
    else
        Check_status
        if [ "$status" == "running" ]; then
            status="${Green_font_prefix}已安装${Font_color_suffix}"
            run_status="${Green_font_prefix}运行中${Font_color_suffix}"
        else
            status="${Green_font_prefix}已安装${Font_color_suffix}"
            run_status="${Red_font_prefix}未运行${Font_color_suffix}"
        fi
        if systemctl is-enabled v2ray.service &>/dev/null; then
            auto_start="${Green_font_prefix}已设置${Font_color_suffix}"
        else
            auto_start="${Red_font_prefix}未设置${Font_color_suffix}"
        fi
    fi
    # 输出状态
    echo -e "脚本版本：${Green_font_prefix}${sh_ver}${Font_color_suffix}"
    echo -e "安装状态：${status}"
    echo -e "运行状态：${run_status}"
    echo -e "开机自启：${auto_start}"
}

# 获取架构
Get_the_schema(){
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='amd64';;
        'x86' | 'i686' | 'i386')     ARCH='386';;
        'aarch64' | 'arm64') ARCH='arm64-v8';;
        'armv7' | 'armv7l')   ARCH='arm32-v7';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
    esac
}

# 显示当前配置
View(){
    # 检查是否安装
    Check_install
    echo -e "${Red_font_prefix}trojan 配置信息${Font_color_suffix}"
    # 读取并显示 port、password、path
    if [[ -f "${CONFIG_FILE}" ]]; then
        port=$(jq -r '.local_port // "未设置"' "${CONFIG_FILE}")
        password=$(jq -r '.password[0] // "未设置"' "${CONFIG_FILE}")
        path=$(jq -r '.websocket.path // "未设置"' "${CONFIG_FILE}")
        # 显示信息
        echo -e "port: ${Green_font_prefix}${port}${Font_color_suffix}"
        echo -e "password: ${Green_font_prefix}${password}${Font_color_suffix}"
        echo -e "path: ${Green_font_prefix}${path}${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}找不到配置文件 ${CONFIG_FILE}，请检查路径是否正确${Font_color_suffix}"
    fi
    Start_Main
}

# 启动
Start() {
    # 检查是否安装
    Check_install
    # 检查运行状态
    if systemctl is-active --quiet trojan-go; then
        echo -e "${Green_font_prefix}trojan 已经在运行中${Font_color_suffix}"
        Start_Main
    fi
    echo -e "${Green_font_prefix}trojan 准备启动中${Font_color_suffix}"
    # 重新加载
    systemctl daemon-reload
    # 启动服务
    if systemctl start trojan-go; then
        echo -e "${Green_font_prefix}trojan 启动命令已发出${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}trojan 启动失败${Font_color_suffix}"
        exit 1
    fi
    # 等待服务启动
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet trojan-go; then
        echo -e "${Green_font_prefix}trojan 启动成功${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}trojan 启动失败${Font_color_suffix}"
        exit 1
    fi
    Start_Main
}

# 停止
Stop() {
    # 检查是否安装
    Check_install
    # 检查运行状态
    if ! systemctl is-active --quiet trojan-go; then
        echo -e "${Green_font_prefix}trojan 已经停止${Font_color_suffix}"
        Start_Main
    fi
    echo -e "${Green_font_prefix}trojan 准备停止中${Font_color_suffix}"
    # 尝试停止服务
    if systemctl stop trojan-go; then
        echo -e "${Green_font_prefix}trojan 停止命令已发出${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}trojan 停止失败${Font_color_suffix}"
        exit 1
    fi
    # 等待服务停止
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet trojan-go; then
        echo -e "${Red_font_prefix}trojan 停止失败${Font_color_suffix}"
        exit 1
    else
        echo -e "${Green_font_prefix}trojan 停止成功${Font_color_suffix}"
    fi
    Start_Main
}

# 重启
Restart() {
    # 检查是否安装
    Check_install
    echo -e "${Green_font_prefix}trojan 准备重启中${Font_color_suffix}"
    # 重启 trojan 服务
    if systemctl restart trojan-go; then
        echo -e "${Green_font_prefix}trojan 重启命令已发出${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}trojan 重启失败${Font_color_suffix}"
        exit 1
    fi
    # 等待服务重启
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet trojan-go; then
        echo -e "${Green_font_prefix}trojan 重启成功${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}trojan 重启失败${Font_color_suffix}"
        exit 1
    fi
    Start_Main
}

# 卸载
Uninstall() {
    # 检查是否安装
    Check_install
    echo -e "${Green_font_prefix}trojan 开始卸载${Font_color_suffix}"
    echo -e "${Green_font_prefix}trojan 卸载命令已发出${Font_color_suffix}"
    # 停止服务
    systemctl stop trojan-go 2>/dev/null || { echo -e "${Red_font_prefix}停止 trojan 服务失败${Font_color_suffix}"; exit 1; }
    systemctl disable trojan-go 2>/dev/null || { echo -e "${Red_font_prefix}禁用 trojan 服务失败${Font_color_suffix}"; exit 1; }
    # 删除服务文件
    rm -f "$SYSTEM_FILE" || { echo -e "${Red_font_prefix}删除服务文件失败${Font_color_suffix}"; exit 1; }
    # 删除文件夹
    rm -rf "$FOLDERS" || { echo -e "${Red_font_prefix}删除相关文件夹失败${Font_color_suffix}"; exit 1; }
    # 删除证书
    rm -rf "$ACME_FILE" || { echo -e "${Red_font_prefix}删除证书失败${Font_color_suffix}"; exit 1; }
    # 重新加载 systemd
    systemctl daemon-reload || { echo -e "${Red_font_prefix}重新加载 systemd 配置失败${Font_color_suffix}"; exit 1; }
    # 等待服务停止
    sleep 3s
    # 检查卸载是否成功
    if [ ! -f "$SYSTEM_FILE" ] && [ ! -d "$FOLDERS" ]; then
        echo -e "${Green_font_prefix}trojan 卸载完成${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}卸载过程中出现问题，请手动检查${Font_color_suffix}"
    fi
    exit 0
}

# 更新脚本
Update_Shell() {
    # 获取当前版本
    echo -e "${Green_font_prefix}开始检查是否有更新${Font_color_suffix}"
    # 获取最新版本号
    sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/thNylHx/Tools/main/Script/trojan-install.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    # 最新版本无需更新
    if [ "$sh_ver" == "$sh_new_ver" ]; then
        echo -e "当前版本：[ ${Green_font_prefix}${sh_ver}${Font_color_suffix} ]"
        echo -e "最新版本：[ ${Green_font_prefix}${sh_new_ver}${Font_color_suffix} ]"
        echo -e "${Green_font_prefix}当前已是最新版本，无需更新${Font_color_suffix}"
        Start_Main
    fi
    echo -e "${Green_font_prefix}检查到已有新版本${Font_color_suffix}"
    echo -e "当前版本：[ ${Green_font_prefix}${sh_ver}${Font_color_suffix} ]"
    echo -e "最新版本：[ ${Green_font_prefix}${sh_new_ver}${Font_color_suffix} ]"
    # 开始更新
    while true; do
        read -p "是否升级到最新版本？(y/n)： " confirm
        case $confirm in
            [Yy]* )
                echo -e "开始下载最新版本：[ ${Green_font_prefix}${sh_new_ver}${Font_color_suffix} ]"
                wget -O trojan-install.sh --no-check-certificate https://raw.githubusercontent.com/thNylHx/Tools/main/Script/trojan-install.sh
                chmod +x trojan-install.sh
                echo -e "更新完成，当前版本已更新为：[ ${Green_font_prefix}v${sh_new_ver}${Font_color_suffix} ]"
                echo -e "5 秒后执行新脚本"
                sleep 5s
                bash trojan-install.sh
                break
                ;;
            [Nn]* )
                echo -e "${Red_font_prefix}更新已取消 ${Font_color_suffix}"
                exit 1
                ;;
            * )
                echo -e "${Red_font_prefix}无效的输入，请输入 y 或 n ${Font_color_suffix}"
                ;;
        esac
    done
    Start_Main
}

# 安装
Install() {
    # 检测是否安装
    if [ -f "$FILE" ]; then
        echo -e "${Green_font_prefix}trojan 已经安装${Font_color_suffix}"
        Start_Main
    fi
    # 更新系统
    apt update && apt dist-upgrade -y
    # 安装插件
    apt-get install jq unzip curl git wget vim dnsutils openssl coreutils grep gawk -y
    # 创建文件夹
    mkdir -p $FOLDERS && cd $FOLDERS || { echo -e "${Red_font_prefix}创建或进入 $FOLDERS 目录失败${Font_color_suffix}"; exit 1; }
    # 获取架构
    Get_the_schema
    echo -e "当前架构：[ ${Green_font_prefix}${ARCH_RAW}${Font_color_suffix} ]"
    # 获取版本信息
    VERSION=$(curl -sSL "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//' || { echo -e "${Red_font_prefix}获取最新版本信息失败${Font_color_suffix}"; exit 1; })
    # 构造文件名
    case "$ARCH" in
            'arm64-v8' | 'arm64-v7' | 's390x' | '386' | 'amd64') FILENAME="trojan-go-linux-${ARCH}.zip";;
            *)       echo -e "不支持的架构：[ ${Red_font_prefix}${ARCH}${Font_color_suffix} ]"; exit 1;;
    esac
    # 输出获取到的最新版本信息
    echo -e "获取到的最新版本：[ ${Green_font_prefix}${VERSION}${Font_color_suffix} ]"
    # 开始下载
    DOWNLOAD_URL="https://github.com/p4gefau1t/trojan-go/releases/download/v${VERSION}/${FILENAME}"
    echo -e "当前版本：[ ${Green_font_prefix}${VERSION}${Font_color_suffix} ]"
    wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }
    echo -e "[ ${Green_font_prefix}${VERSION}${Font_color_suffix} ] 下载完成，开始安装"
    # 解压文件
    unzip "$FILENAME" && rm "$FILENAME" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
    # 授权
    chmod 755 trojan-go
    # 记录版本信息
    echo "$VERSION" > "$VERSION_FILE"
    # 下载系统配置文件
    echo -e "${Green_font_prefix}开始下载 trojan 的 Service 系统配置${Font_color_suffix}"
    wget -O "$SYSTEM_FILE" https://raw.githubusercontent.com/thNylHx/Tools/main/Service/trojan-go.service && chmod 755 "$SYSTEM_FILE"
    echo -e "${Green_font_prefix}trojan 安装成功，开始配置${Font_color_suffix}"
    # 开始配置 config 文件
    Configure
}

# 更新
Update() {
    # 检查是否安装
    Check_install
    echo -e "${Green_font_prefix}开始检查是否有更新${Font_color_suffix}"
    cd $FOLDERS
    # 获取当前版本
    CURRENT_VERSION=$(Get_current_version)
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')
    # 开始更新
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo -e "当前版本：[ ${Green_font_prefix}${CURRENT_VERSION}${Font_color_suffix} ]"
        echo -e "最新版本：[ ${Green_font_prefix}${LATEST_VERSION}${Font_color_suffix} ]"
        echo -e "当前已是最新版本，无需更新！"
        Start_Main
    fi
    echo -e "${Green_font_prefix}检查到已有新版本${Font_color_suffix}"
    echo -e "当前版本：[ ${Green_font_prefix}${CURRENT_VERSION}${Font_color_suffix} ]"
    echo -e "最新版本：[ ${Green_font_prefix}${LATEST_VERSION}${Font_color_suffix} ]"
    while true; do
        read -p "是否要更新到最新版本？(y/n): " confirm
        case $confirm in
            [Yy]* )
                # 获取架构
                Get_the_schema
                # 构造文件名
                case "$ARCH" in
                    'arm64-v8' | 'arm64-v7' | 's390x' | '386' | 'amd64') FILENAME="trojan-go-linux-${ARCH}.zip";;
                    *)       echo -e "不支持的架构：[ ${Red_font_prefix}${ARCH}${Font_color_suffix} ]"; exit 1;;
                esac
                # 开始下载
                DOWNLOAD_URL="https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip"
                echo -e "开始下载最新版本：[ ${Green_font_prefix}${LATEST_VERSION}${Font_color_suffix} ]"
                wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }
                echo -e "[ ${Green_font_prefix}${LATEST_VERSION}${Font_color_suffix} ] 下载完成，开始更新"
                # 解压文件
                unzip "$FILENAME" && rm "$FILENAME" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
                # 授权
                chmod 755 trojan-go
                # 更新版本信息
                echo "$LATEST_VERSION" > "$VERSION_FILE"
                # 重启
                systemctl restart trojan-go
                echo -e "更新完成，当前版本已更新为：[ ${Green_font_prefix}v${LATEST_VERSION}${Font_color_suffix} ]"
                # 检查并显示服务状态
                if systemctl is-active --quiet trojan-go; then
                    echo -e "当前状态：[ ${Green_font_prefix}运行中${Font_color_suffix} ]"
                else
                    echo -e "当前状态：[ ${Red_font_prefix}未运行${Font_color_suffix} ]"
                    Start_Main
                fi
                Start_Main
                ;;
            [Nn]* )
                echo -e "${Red_font_prefix}更新已取消 ${Font_color_suffix}"
                Start_Main
                ;;
            * )
                echo -e "${Red_font_prefix}无效的输入，请输入 y 或 n ${Font_color_suffix}"
                ;;
        esac
    done
    Start_Main
}

# 配置 trojan
Configure() {
    # 检查是否安装
    Check_install
    # 下载基础配置文件
    CONFIG_URL="https://raw.githubusercontent.com/thNylHx/Tools/main/Config/trojan/trojan.json"
    curl -s -o "$CONFIG_FILE" "$CONFIG_URL"
    # 端口处理
    read -p "请输入监听端口 (留空以随机生成端口): " PORT
    if [[ -z "$PORT" ]]; then
        PORT=$(shuf -i 10000-65000 -n 1)
        echo -e "随机生成的监听端口: ${Green_font_prefix}$PORT${Font_color_suffix}"
    elif [[ "$PORT" -lt 10000 || "$PORT" -gt 65000 ]]; then
        echo -e "${Red_font_prefix}端口号必须在10000到65000之间。${Font_color_suffix}"
        exit 1
    fi
    # UUID处理
    read -p "请输入 trojan 密码 (留空以随机生成): " UUID
    if [[ -z "$UUID" ]]; then
        if command -v uuidgen >/dev/null 2>&1; then
            UUID=$(uuidgen)
        else
            UUID=$(cat /proc/sys/kernel/random/uuid)
        fi
        echo -e "随机生成的密码: ${Green_font_prefix}$UUID${Font_color_suffix}"
    fi
    # 获取远程地址
    read -p "请输入远程地址 (默认有): " REMOTE
    if [[ -z "$REMOTE" ]]; then
        REMOTE="192.83.167.78"
        echo -e "远程地址: ${Green_font_prefix}$REMOTE${Font_color_suffix}"
    fi
    # WebSocket 路径处理
    read -p "请输入 WebSocket 路径 (留空以生成随机路径): " WS_PATH
    if [[ -z "$WS_PATH" ]]; then
         WS_PATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
        echo -e "随机生成的 WebSocket 路径: ${Green_font_prefix}/$WS_PATH${Font_color_suffix}"
    else
        WS_PATH="${WS_PATH#/}"
        echo -e "WebSocket 路径: ${Green_font_prefix}/$WS_PATH${Font_color_suffix}"
    fi
    read -p "请输入 WebSocket 主机 (默认: bing.com): " WS_HOST
    WS_HOST=${WS_HOST:-bing.com}
    echo -e "主机名: ${Green_font_prefix}$WS_HOST${Font_color_suffix}"
    # 读取配置文件
    echo -e "${Green_font_prefix}读取配置文件${Font_color_suffix}"
    config=$(cat "$CONFIG_FILE")
    # 修改配置文件
    echo -e "${Green_font_prefix}修改配置文件${Font_color_suffix}"
    config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" --arg remote "$REMOTE" --arg ws_path "/$WS_PATH" --arg ws_host "$WS_HOST" '
        .local_port = ($port | tonumber) |
        .remote_addr = $remote |
        .password[0] = $uuid |
        .websocket.enabled = true |
        .websocket.path = $ws_path |
        .websocket.host = $ws_host
    ')
    # 写入配置文件
    echo -e "${Green_font_prefix}写入配置文件${Font_color_suffix}"
    echo "$config" > "$CONFIG_FILE"
    # 验证修改后的配置文件
    echo -e "${Green_font_prefix}验证修改后的配置文件格式${Font_color_suffix}"
    if ! jq . "$CONFIG_FILE" >/dev/null 2>&1; then
        echo -e "${Red_font_prefix}修改后的配置文件格式无效，请检查文件${Font_color_suffix}"
        exit 1
    fi
    # 提示保存位置
    echo -e "${Green_font_prefix}trojan 配置已完成并保存到 ${CONFIG_FILE} 文件夹${Font_color_suffix}"
    echo -e "${Green_font_prefix}trojan 配置完成，正在启动中${Font_color_suffix}"
    # 重新加载系统服务
    systemctl daemon-reload
    # 设置为开机自启
    systemctl enable trojan-go
    # 立即启动
    systemctl start trojan-go
    # # 运行状况
    # systemctl status trojan-go
    # 引导语
    echo -e "${Green_font_prefix}恭喜你，你的 trojan 已经配置完成${Font_color_suffix}"
    echo -e "${Red_font_prefix}trojan 需要申请证书后使用，证书申请完成后，选择 5 启动 trojan 即可${Font_color_suffix}"
    # 检查并显示服务状态
    if systemctl is-active --quiet trojan; then
        echo -e "当前状态：[ ${Green_font_prefix}运行中${Font_color_suffix} ]"
    else
        echo -e "当前状态：[ ${Red_font_prefix}未运行${Font_color_suffix} ]"
        Start_Main
    fi
    # 返回主菜单
    Start_Main
}

# 创建存储证书的目录
mkdir -p $SSL_FILE

# 检查是否安装 acme.sh
Install_acme_if_needed(){
    if ! command -v ~/.acme.sh/acme.sh &>/dev/null; then
        echo "acme.sh 未安装，正在安装"
        curl https://get.acme.sh | sh || { echo "安装失败"; exit 1; }
    else
        echo "acme.sh 已经安装"
    fi
}

# 检查是否已有该域名的证书
Check_domain_name(){
    local currentCert=$(~/.acme.sh/acme.sh --list | grep ${DOMAIN} | wc -l)
    if [ ${currentCert} -ne 0 ]; then
        local certInfo=$(~/.acme.sh/acme.sh --list)
        echo -e "${Red_font_prefix}错误：当前环境已有对应域名的证书，无法重复申请${Font_color_suffix}"
        echo "$certInfo"
        exit 1
    else
        echo "域名合法性校验通过"
    fi
}

# 自签证书申请函数
Request_self_cert() {
    echo -e "${Green_font_prefix}申请自签名证书中${Font_color_suffix}" 
    # 读取用户输入的域名，如果未输入则默认使用 bing.com
    read -p "请输入伪装域名（默认：bing.com）： " DOMAIN
    DOMAIN=${DOMAIN:-bing.com}
    # 生成自签名证书
    openssl req -newkey rsa:2048 -nodes -keyout $SSL_FILE/server.key -x509 -days 36500 -out $SSL_FILE/server.crt -subj "/CN=$DOMAIN"
    echo -e "${Green_font_prefix}自签名证书生成完成${Font_color_suffix}"
}

# ACME Standalone 证书申请
Request_acme_cert() {
    # 检查安装情况
    Install_acme_if_needed
    # 安装必要插件
    apt-get install -y socat curl dnsutils openssl coreutils grep gawk
    # 选择 CA 提供商
    Select_Cert_Provider
    # 生成随机邮箱地址
    Generate_random_email() {
        local RANDOM_NUMBER=$(openssl rand -hex 12 | tr -dc 'a-z0-9' | head -c 15)
        local EMAIL="${RANDOM_NUMBER}@spyemail.com"
        echo "$EMAIL"
    }
    # 获取用户输入的域名
    read -p "请输入你的域名（用于证书申请）: " DOMAIN
    # 获取用户输入的电子邮件
    read -p "请输入申请证书的电子邮件（默认为随机生成邮箱）： " EMAIL
    if [ -z "$EMAIL" ]; then
        EMAIL=$(Generate_random_email)
        echo "未输入电子邮件，使用生成的随机邮箱地址： $EMAIL"
    else
        echo "使用用户输入的邮箱地址： $EMAIL"
    fi
    # 检查是否已有该域名的证书
    Check_domain_name
    # 获取本机的公网 IP 地址
    LOCAL_IP_V4=$(curl -s ifconfig.me)
    LOCAL_IP_V6=$(curl -s ifconfig.co)
    # 获取域名的 A 记录和 AAAA 记录 IP 地址
    DOMAIN_IP_V4=$(dig +short A "$DOMAIN" | tail -n 1)
    DOMAIN_IP_V6=$(dig +short AAAA "$DOMAIN" | tail -n 1)
    # 检查域名是否解析到本机 IP 地址
    if [[ "$DOMAIN_IP_V4" == "$LOCAL_IP_V4" || "$DOMAIN_IP_V6" == "$LOCAL_IP_V6" ]]; then
        echo "域名验证通过，继续申请证书"
    else
        echo -e "${Red_font_prefix}错误：域名 $DOMAIN 未解析到本机 IP 地址。当前解析 IPv4 地址为 $DOMAIN_IP_V4，IPv6 地址为 $DOMAIN_IP_V6。${Font_color_suffix}"
        exit 1
    fi 
    # 申请证书
    ~/.acme.sh/acme.sh --set-default-ca --server "$CA_SERVER"
    ~/.acme.sh/acme.sh --issue --standalone -d "$DOMAIN" --email "$EMAIL" --keylength ec-256 --log || { echo "证书申请失败！"; rm -rf ~/.acme.sh/${DOMAIN}; exit 1; }
    # 将证书和私钥复制到指定目录
    ~/.acme.sh/acme.sh --install-cert -d "$DOMAIN" \
        --ecc \
        --cert-file $SSL_FILE/server.crt \
        --key-file $SSL_FILE/server.key \
        --fullchain-file $SSL_FILE/fullchain.crt || { echo "证书安装失败！"; rm -rf ~/.acme.sh/${DOMAIN}; exit 1; }
    # 启用证书自动更新
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade || { echo "自动更新设置失败"; chmod 755 $SSL_FILE; exit 1; }
    echo -e "${Green_font_prefix}ACME 证书申请完成并保存至 $SSL_FILE 目录，证书已开启自动更新${Font_color_suffix}"
    ls -lah $SSL_FILE
    chmod 755 $SSL_FILE
}

# CF DNS API 证书申请
Request_cf_cert() {
    # 检查安装情况
    Install_acme_if_needed
    # 安装必要插件
    apt-get install -y curl dnsutils openssl coreutils grep gawk
    # 选择 CA 提供商
    Select_Cert_Provider
    # 使用说明
    echo -e ""
    echo "******使用说明******"
    echo "该脚本将使用 Acme 脚本申请证书，使用时需保证:"
    echo "1. 知晓 Cloudflare 注册邮箱"
    echo "2. 知晓 Cloudflare Global API Key"
    echo "3. 域名已通过 Cloudflare 进行解析到当前服务器"
    echo "4. 该脚本申请证书默认安装路径为 /root/v2ray/ssl 目录"
    read -p "我已确认以上内容 [y/n]: " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "操作已取消。"
        exit 0
    fi
    # 获取用户输入的域名、Cloudflare API 密钥和邮箱
    read -p "请输入域名（用于证书申请）: " CF_Domain
    read -p "请输入 Cloudflare Global API Key: " CF_GlobalKey
    read -p "请输入 Cloudflare 注册邮箱: " CF_AccountEmail
    # 设置 Cloudflare API 凭据
    export CF_Key="$CF_GlobalKey"
    export CF_Email="$CF_AccountEmail"
    # 注册账户
    ~/.acme.sh/acme.sh --register-account -m "$CF_AccountEmail" || { echo "账户注册失败！"; exit 1; }
    # 设置默认 CA 为 ZeroSSL
    ~/.acme.sh/acme.sh --set-default-ca --server zerossl || { echo "修改默认 CA 失败！"; exit 1; }
    # 检查是否已有该域名的证书
    Check_domain_name
    # 申请证书
    ~/.acme.sh/acme.sh --set-default-ca --server "$CA_SERVER"
    ~/.acme.sh/acme.sh --issue --dns dns_cf -d "$CF_Domain" -d "*.$CF_Domain" --email "$CF_AccountEmail" --keylength ec-256 || { echo "证书申请失败！"; rm -rf ~/.acme.sh/${CF_Domain}; exit 1; }
    # 将证书和私钥复制到指定目录
    ~/.acme.sh/acme.sh --install-cert -d "$CF_Domain" -d "*.$CF_Domain" \
        --ecc \
        --cert-file $SSL_FILE/server.crt \
        --key-file $SSL_FILE/server.key \
        --fullchain-file $SSL_FILE/fullchain.crt || { echo "证书安装失败！"; rm -rf ~/.acme.sh/${CF_Domain}; exit 1; }
    # 启用证书自动更新
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade || { echo "自动更新设置失败"; chmod 755 $SSL_FILE; exit 1; }
    echo -e "${Green_font_prefix}ACME 证书申请完成并保存至 $SSL_FILE 目录，证书已开启自动更新${Font_color_suffix}"
    ls -lah $SSL_FILE
    chmod 755 $SSL_FILE
}

# 申请证书
Request_Cert() {
    clear
    echo "================================="
    echo -e "${Green_font_prefix}欢迎使用 ACME 一键 SSL 证书申请脚本 Beta 版${Font_color_suffix}"
    echo -e "${Green_font_prefix}作者：${Font_color_suffix}${Red_font_prefix}thNylHx${Font_color_suffix}"
    echo -e "${Green_font_prefix}安装过程中可以按 ctrl+c 强制退出${Font_color_suffix}"
    echo "================================="
    echo "使用说明书："
    echo "1. 该脚本提供三种方式实现证书签发"
    echo "2. 使用 ACME Standalone 的方式申请证书，需要开放端口"
    echo "3. 使用 DNS API 的方式申请证书，需要对 DNS 提供商的 API 进行配置（如 Cloudflare API 密钥）"
    echo "4. 使用自签申请证书，适用于没有域名"
    echo "================================="
    echo -e "${Green_font_prefix}1${Font_color_suffix}、自签证书申请"
    echo -e "${Green_font_prefix}2${Font_color_suffix}、DNS API 证书申请"
    echo -e "${Green_font_prefix}3${Font_color_suffix}、Standalone 证书申请"
    echo "================================="
    # 默认选择 2（DNS API 证书申请）
    read -p "请选择证书申请方式（默认2）: " confirm
    confirm=${confirm:-2}
    # 选择方式
    echo -e "${Green_font_prefix}你选择了 ${confirm}${Font_color_suffix}"
    case $confirm in
        1) Request_self_cert ;;
        2) Request_cf_cert ;;
        3) Request_acme_cert ;;
        *) echo -e "${Red_font_prefix}无效选择，默认使用 DNS API 证书申请${Font_color_suffix}"; Request_cf_cert ;;
    esac
}

# 主菜单
Main() {
    clear
    echo "================================="
    echo -e "${Green_font_prefix}欢迎使用 trojan 一键脚本${Font_color_suffix}"
    echo -e "${Green_font_prefix}作者：${Font_color_suffix}${Red_font_prefix}thNylHx${Font_color_suffix}"
    echo -e "${Green_font_prefix}请保证科学上网已经开启${Font_color_suffix}"
    echo -e "${Green_font_prefix}安装过程中可以按 ctrl+c 强制退出${Font_color_suffix}"
    echo -e "${Red_font_prefix}特别提醒：trojan 安装后，先申请证书，然后在启动！${Font_color_suffix}"
    echo "================================="
    echo -e "${Green_font_prefix}0${Font_color_suffix}、更新脚本"
    echo "---------------------------------"
    echo -e "${Green_font_prefix}1${Font_color_suffix}、安装 trojan"
    echo -e "${Green_font_prefix}2${Font_color_suffix}、更新 trojan"
    echo -e "${Green_font_prefix}3${Font_color_suffix}、配置 trojan"
    echo -e "${Green_font_prefix}4${Font_color_suffix}、卸载 trojan"
    echo -e "${Green_font_prefix}5${Font_color_suffix}、启动 trojan"
    echo -e "${Green_font_prefix}6${Font_color_suffix}、停止 trojan"
    echo -e "${Green_font_prefix}7${Font_color_suffix}、重启 trojan"
    echo "---------------------------------"
    echo -e "${Green_font_prefix}8${Font_color_suffix}、查看配置"
    echo -e "${Green_font_prefix}9${Font_color_suffix}、申请证书"
    echo -e "${Green_font_prefix}10${Font_color_suffix}、退出脚本"
    echo "================================="
    Show_Status
    echo "================================="
    read -p "请输入数字选择[0-10]: " num
    case "$num" in
        1) Install ;;
        2) Update ;;
        3) Configure ;;
        4) Uninstall ;;
        5) Start ;;
        6) Stop ;;
        7) Restart ;;
        8) View ;;
        9) Request_Cert ;;
        0) Update_Shell ;;
        10) exit 0 ;; 
        *) echo -e "${Red_font_prefix}无效选项，请重新选择${Font_color_suffix}"
           exit 1 ;;
    esac
}

# 启动主菜单
Main
