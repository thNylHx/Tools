#!/bin/bash
#!name = Trojan 一键脚本
#!desc = 支持，安装、更新、卸载等
#!date = 2024-08-18 09:00
#!author = thNylHx ChatGPT

set -e -o pipefail

# 定义颜色代码
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"

# 定义脚本版本
sh_ver="1.1.4"

# Trojan 可执行文件的路径
FILE="/root/Trojan/trojan-go"
TROJAN_FILE="/root/Trojan"
SSL_FILE="/root/Trojan/ssl"
CONFIG_FILE="/root/Trojan/config.json"
VERSION_FILE="/root/Trojan/version.txt"
SYSTEM_FILE="/etc/systemd/system/trojan-go.service"

# 返回主菜单
Start_Main() {
    echo && echo -n -e "${Red_font_prefix}* 按回车返回主菜单 *${Font_color_suffix}" && read temp
    Main
}

# 检查是否已安装 Trojan
Check_install(){
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}Trojan 未安装${Font_color_suffix}"
        Start_Main
    fi
}

# 检查Trojan服务状态
check_status() {
    if pgrep -x "trojan-go" > /dev/null; then
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
        echo "Trojan 未安装"
    fi
}

# 显示当前脚本和服务状态
Show_Status() {
    if [ ! -f "$FILE" ]; then
        status="${Red_font_prefix}Trojan 未安装${Font_color_suffix}"
    else
        check_status
        if [ "$status" == "running" ]; then
            status="${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}运行中${Font_color_suffix}"
        else
            status="${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未运行${Font_color_suffix}"
        fi
    fi
    echo -e "版本：${Green_font_prefix}${sh_ver}${Font_color_suffix}"
    echo -e "状态：${status}"
}

# 显示当前配置
View(){
    # 检查是否安装 Trojan
    Check_install
    echo -e "${Red_font_prefix}Trojan 配置信息${Font_color_suffix}"
    # 读取并显示端口和 UUID
    if [[ -f "${CONFIG_FILE}" ]]; then
        local_port=$(jq -r '.local_port' "${CONFIG_FILE}")
        password=$(jq -r '.password[0]' "${CONFIG_FILE}")
        # 如果读取值为 null，则显示“未设置”
        local_port=${local_port:-"未设置"}
        password=${password:-"未设置"}
        echo -e "port: ${Green_font_prefix}${local_port}${Font_color_suffix}"
        echo -e "password: ${Green_font_prefix}${password}${Font_color_suffix}"
    else
        echo -e "${Error} 找不到配置文件 ${CONFIG_FILE}，请检查路径是否正确！"
    fi
    Start_Main
}

# 获取 CPU 架构
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

# 启动 Trojan
Start() {
    # 检测是否安装
    Check_install
    # 判断 Trojan 是否已经运行
    if systemctl is-active --quiet trojan-go; then
        echo -e "${Green_font_prefix}Trojan 已经在运行中${Font_color_suffix}"
        Start_Main
    fi
    echo -e "${Green_font_prefix}Trojan 启动中...${Font_color_suffix}"
    # 重新加载
    systemctl daemon-reload
    # 启动服务
    if systemctl start trojan-go; then
        echo -e "${Green_font_prefix}Trojan 启动命令已发出${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}Trojan 启动失败${Font_color_suffix}"
        exit 1
    fi
    # 等待服务启动
    sleep 2
    # 检查服务状态
    if systemctl is-active --quiet trojan-go; then
        echo -e "${Green_font_prefix}Trojan 启动成功${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}Trojan 启动失败，服务未激活${Font_color_suffix}"
        exit 1
    fi
    Start_Main
}

# 停止 Trojan
Stop() {
    # 检查 Trojan 是否已安装
    Check_install
    # 检查是否运行
    if ! systemctl is-active --quiet trojan-go; then
        echo -e "${Green_font_prefix}Trojan 已经停止${Font_color_suffix}"
        Start_Main
    fi
    echo -e "${Green_font_prefix}Trojan 停止中...${Font_color_suffix}"
    # 尝试停止服务
    if systemctl stop trojan-go; then
        echo -e "${Green_font_prefix}Trojan 停止命令已发出${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}Trojan 停止失败${Font_color_suffix}"
        exit 1
    fi
    echo -e "${Green_font_prefix}Trojan 停止完成${Font_color_suffix}"
    # 检查服务状态
    check_status
    Start_Main
}

# 重启 Trojan
Restart() {
    # 检查 Trojan 是否已安装
    Check_install
    echo -e "${Green_font_prefix}Trojan 重启中...${Font_color_suffix}"
    # 重启 Trojan 服务
    if systemctl restart trojan-go; then
        echo -e "${Green_font_prefix}Trojan 重启命令已发出${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}Trojan 重启失败${Font_color_suffix}"
        exit 1
    fi
    echo -e "${Green_font_prefix}Trojan 重启成功${Font_color_suffix}"
    # 检查服务状态
    check_status
    Start_Main
}

# 卸载 Trojan
Uninstall() {
    # 检查是否安装 Trojan
    Check_install
    echo -e "${Red_font_prefix}Trojan 卸载中...${Font_color_suffix}"
    # 停止服务
    systemctl stop trojan-go
    systemctl disable trojan-go
    # 删除服务文件
    rm -f "$SYSTEM_FILE"
    # 删除文件
    rm -rf "$TROJAN_FILE"
    # 重新加载 systemd
    systemctl daemon-reload
    # 检查卸载是否成功
    if [ ! -f "$SYSTEM_FILE" ] && [ ! -d "$TROJAN_FILE" ]; then
        echo -e "${Green_font_prefix}Trojan 卸载完成${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}卸载过程中出现问题，请手动检查${Font_color_suffix}"
    fi
    exit 1
}

# 更新脚本
Update_Shell() {
    # 获取当前版本
    echo -e "当前版本为 ${sh_ver}，开始检测最新版本..."
    # 获取最新版本号
    sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/thNylHx/Tools/main/Script/trojan-install.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    if [ "$sh_ver" == "$sh_new_ver" ]; then
        echo -e "当前版本: ${Green_font_prefix}${sh_ver}${Font_color_suffix}"
        echo -e "最新版本: ${Green_font_prefix}${sh_new_ver}${Font_color_suffix}"
        echo -e "${Green_font_prefix}当前已是最新版本，无需更新！${Font_color_suffix}"
        Start_Main
    fi
    echo -e "当前版本: ${Green_font_prefix}${sh_ver}${Font_color_suffix}"
    echo -e "最新版本: ${Green_font_prefix}${sh_new_ver}${Font_color_suffix}"
    # 开始更新
    read -p "是否升级到最新版本？(y/n): " confirm
    case $confirm in
        [Yy]* )
            echo -e "${Green_font_prefix}开始更新${Font_color_suffix}"
            wget -O trojan-install.sh --no-check-certificate https://raw.githubusercontent.com/thNylHx/Tools/main/Script/trojan-install.sh
            chmod +x trojan-install.sh
            echo -e "更新完成，当前版本已更新为 ${Green_font_prefix}v${sh_new_ver}${Font_color_suffix}"
            echo -e "5 秒后执行新脚本..."
            sleep 5s
            bash trojan-install.sh
            ;;
        [Nn]* )
            echo -e "${Red_font_prefix}更新已取消。${Font_color_suffix}"
            exit 1
            ;;
        * )
            echo -e "${Red_font_prefix}无效的输入。${Font_color_suffix}"
            exit 1
            ;;
    esac
    Start_Main
}

# 安装 Trojan
Install() {
    # 检测是否安装
    if [ -f "$FILE" ]; then
        echo -e "${Green_font_prefix}Trojan 已经安装${Font_color_suffix}"
        Start_Main
    fi
    # 更新系统
    apt update && apt dist-upgrade -y
    # 开始安装
    echo -e "${Green_font_prefix}Trojan 安装中...${Font_color_suffix}"
    # 创建文件夹
    mkdir -p /root/Trojan && cd /root/Trojan || { echo -e "${Red_font_prefix}创建或进入 /root/Trojan 目录失败${Font_color_suffix}"; exit 1; }
    # 获取的架构
    Get_the_schema
    echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"
    # 获取版本信息
    VERSION=$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')
    if [ -z "$VERSION" ]; then
        echo -e "${Red_font_prefix}获取最新版本信息失败${Font_color_suffix}"
        exit 1
    fi
    # 输出获取到的最新版本信息
    echo -e "${Green_font_prefix}获取到的最新版本：${VERSION}${Font_color_suffix}"
    # 下载 trojan-go
    echo -e "${Green_font_prefix}开始下载 trojan-go${Font_color_suffix}"
    wget -t 3 -T 30 "https://github.com/p4gefau1t/trojan-go/releases/download/v${VERSION}/trojan-go-linux-${ARCH}.zip"  || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }
    echo -e "${Green_font_prefix}trojan-go 下载完成, 开始部署${Font_color_suffix}"
    unzip "trojan-go-linux-${ARCH}.zip" && rm "trojan-go-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
    # 授权
    chmod 755 trojan-go
    # 记录版本信息
    echo "$VERSION" > "$VERSION_FILE"
    # 下载系统配置文件
    wget -O "$SYSTEM_FILE" https://raw.githubusercontent.com/thNylHx/Tools/main/Service/trojan-go.service && chmod 755 "$SYSTEM_FILE"
    echo -e "${Green_font_prefix}Trojan 安装成功，开始配置配置文件${Font_color_suffix}"
    # 开始配置 config 文件
    Configure
}

# 更新 Trojan
Update() {
    # 检测是否安装
    Check_install
    echo -e "${Green_font_prefix}Trojan 检查是否有更新${Font_color_suffix}"
    cd /root/Trojan
    current_version=$(get_current_version)
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')
    # 开始更新
    if [[ "$current_version" == "$LATEST_VERSION" ]]; then
        echo -e "${Green_font_prefix}当前版本: (v${current_version})${Font_color_suffix}"
        echo -e "${Green_font_prefix}最新版本: (v${LATEST_VERSION})${Font_color_suffix}"
        echo -e "当前已是最新版本，无需更新！"
        Start_Main
    else
        echo -e "${Red_font_prefix}当前版本: ${current_version}${Font_color_suffix}"
        echo -e "${Green_font_prefix}最新版本: ${LATEST_VERSION}${Font_color_suffix}"
        read -p "是否要更新到最新版本？(y/n): " confirm
        case $confirm in
            [Yy]* )
                echo -e "${Green_font_prefix}Trojan 开始更新${Font_color_suffix}"
                Get_the_schema
                echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"
                echo -e "${Green_font_prefix}开始下载最新版本的 trojan-go${Font_color_suffix}"
                wget -P /root/Trojan "https://github.com/p4gefau1t/trojan-go/releases/download/v${LATEST_VERSION}/trojan-go-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }
                echo -e "${Green_font_prefix}trojan-go 下载完成，开始部署${Font_color_suffix}"
                unzip -o "trojan-go-linux-${ARCH}.zip" && rm "trojan-go-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
                echo "$LATEST_VERSION" > "$VERSION_FILE"
                # 重启 Trojan-Go
                systemctl restart trojan-go
                echo -e "${Green_font_prefix}Trojan 更新完成，当前版本已更新为 v${LATEST_VERSION}${Font_color_suffix}"
                ;;
            [Nn]* )
                echo -e "${Red_font_prefix}更新已取消。${Font_color_suffix}"
                exit 1
                ;;
            * )
                echo -e "${Red_font_prefix}无效的输入。${Font_color_suffix}"
                exit 1
                ;;
        esac
    fi
    Start_Main
}

# 配置 Trojan
Configure() {
    # 检查是否安装 Trojan
    Check_install
    echo -e "${Green_font_prefix}Trojan 开始配置${Font_color_suffix}"
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
    read -p "请输入 Trojan 密码 (留空以随机生成): " UUID
    if [[ -z "$UUID" ]]; then
        if command -v uuidgen >/dev/null 2>&1; then
            UUID=$(uuidgen)
        else
            UUID=$(cat /proc/sys/kernel/random/uuid)
        fi
        echo -e "随机生成的密码: ${Green_font_prefix}$UUID${Font_color_suffix}"
    fi
    # 获取远程地址
    read -p "请输入远程地址 (输入远程伪装地址): " REMOTE
    if [[ -z "$REMOTE" ]]; then
        REMOTE="192.83.167.78"
    fi
    # 写入配置文件
    wget -O "$CONFIG_FILE" https://raw.githubusercontent.com/thNylHx/Tools/main/Config/Trojan/Trojan.json
    # 使用 sed 替换 JSON 文件中的占位符
    sed -i "s#PORT#$PORT#" "$CONFIG_FILE"
    sed -i "s#REMOTE#$REMOTE#" "$CONFIG_FILE"
    sed -i "s#UUID#$UUID#" "$CONFIG_FILE"
    echo -e "${Green_font_prefix}Trojan 配置完成，正在启动中...${Font_color_suffix}"
    # 重新加载系统服务
    systemctl daemon-reload
    # 设置为开机自启
    systemctl enable trojan-go
    # 立即启动
    systemctl start trojan-go
    # 运行状况
    systemctl status trojan-go
    # 检查服务状态
    check_status
    # 返回主菜单
    Start_Main
}

# 申请证书
Request_Cert() {
    echo "=============================="
    echo "请选择证书申请方式："
    echo "=============================="
    echo -e "${Green_font_prefix}1${Font_color_suffix}、自签证书申请"
    echo -e "${Green_font_prefix}2${Font_color_suffix}、CF 证书申请(暂时不支持)"
    echo -e "${Green_font_prefix}3${Font_color_suffix}、ACME 证书申请"
    echo "=============================="
    read -p "输入数字选择 (1-3): " confirm
    case $confirm in
        1)
        generate_self_signed_cert
        ;;
        2)
        request_cf_cert
        ;;
        3)
        request_acme_cert
        ;;
        *)
        echo -e "${Red_font_prefix}无效的选项。${Font_color_suffix}"
        exit 1
        ;;
    esac
}

# 自签证书申请
generate_self_signed_cert() {
    echo -e "${Green_font_prefix}生成自签名证书中...${Font_color_suffix}" 
    # 读取用户输入的域名
    read -p "请输入伪装域名（例如：bing.com）： " DOMAIN
    # 创建存储证书的目录
    mkdir -p /root/Trojan/ssl
    # 生成自签名证书
    openssl req -newkey rsa:2048 -nodes -keyout /root/Trojan/ssl/server.key -x509 -days 365 -out /root/Trojan/ssl/server.crt -subj "/C=CN/ST=Province/L=City/O=Organization/OU=Department/CN=$DOMAIN"
    echo -e "${Green_font_prefix}自签名证书生成完成！${Font_color_suffix}"
}

# ACME 证书申请
request_acme_cert() {
    echo -e "${Green_font_prefix}申请 ACME 证书中...${Font_color_suffix}"
    # 安装必要的软件包
    apt-get update
    apt-get install -y curl socat
    # 安装 acme.sh 脚本
    curl https://get.acme.sh | sh
    # 创建存储证书的目录
    mkdir -p /root/Trojan/ssl
    # 获取用户输入的域名和邮箱
    read -p "请输入域名（用于证书申请）： " DOMAIN
    read -p "请输入电子邮件（用于接收通知）： " EMAIL
    # 停止可能占用 80 和 443 端口的服务
    systemctl stop nginx
    systemctl stop apache2
    # 使用 acme.sh 的 standalone 模式申请证书
    ~/.acme.sh/acme.sh --issue --standalone -d "$DOMAIN" --email "$EMAIL" --keylength ec-256
    # 将证书和私钥复制到指定目录
    ~/.acme.sh/acme.sh --install-cert -d "$DOMAIN" \
        --ecc \
        --cert-file /root/Trojan/ssl/server.crt \
        --key-file /root/Trojan/ssl/server.key \
        --fullchain-file /root/Trojan/ssl/fullchain.crt
    # 重新启动可能被停止的服务
    systemctl start nginx
    systemctl start apache2
    echo -e "${Green_font_prefix}ACME 证书申请完成并保存至 /root/Trojan/ssl 目录！${Font_color_suffix}"
}

# CF证书申请
request_cf_cert() {
     echo -e "${Green_font_prefix}暂时不支持${Font_color_suffix}"
}

# 主菜单
Main() {
    clear
    echo "=============================="
    echo -e "${Green_font_prefix}欢迎使用 Trojan 一键脚本${Font_color_suffix}"
    echo -e "${Green_font_prefix}作者：${Font_color_suffix}${Red_font_prefix}thNylHx${Font_color_suffix}"
    echo -e "${Green_font_prefix}请保证科学上网已经开启${Font_color_suffix}"
    echo -e "${Green_font_prefix}安装过程中可以按 ctrl+c 强制退出${Font_color_suffix}"
    echo -e "${Red_font_prefix}特别提醒：Trojan 安装后，先申请证书，然后在启动！${Font_color_suffix}"
    echo "=============================="
    echo -e "${Green_font_prefix}1${Font_color_suffix}、 安装 Trojan"
    echo -e "${Green_font_prefix}2${Font_color_suffix}、 更新 Trojan"
    echo -e "${Green_font_prefix}3${Font_color_suffix}、 配置 Trojan"
    echo -e "${Green_font_prefix}4${Font_color_suffix}、 卸载 Trojan"
    echo -e "${Green_font_prefix}5${Font_color_suffix}、 启动 Trojan"
    echo -e "${Green_font_prefix}6${Font_color_suffix}、 停止 Trojan"
    echo -e "${Green_font_prefix}7${Font_color_suffix}、 重启 Trojan"        
    echo -e "${Green_font_prefix}8${Font_color_suffix}、 查看配置"
    echo -e "${Green_font_prefix}9${Font_color_suffix}、 申请证书"
    echo -e "${Green_font_prefix}10${Font_color_suffix}、更新脚本"
    echo -e "${Green_font_prefix}0${Font_color_suffix}、 退出"
    echo "=============================="
    Show_Status
    echo "=============================="
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
        10) Update_Shell ;;
        0) exit 0 ;;
        *) echo -e "${Red_font_prefix}无效的选择，请输入 0 到 10 之间的数字。${Font_color_suffix}" ;;
    esac
}

# 启动主菜单
Main
