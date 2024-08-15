#!/bin/bash

# wget -O trojan-install.sh --no-check-certificate https://raw.githubusercontent.com/thNylHx/Tools/main/Script/trojan-install.sh && chmod +x trojan-install.sh && ./trojan-install.sh

# 定义颜色代码
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"

# 定义脚本版本
sh_ver="1.0.7"

# Trojan 可执行文件的路径
FILE="/root/Trojan/trojan-go"

clear
echo -e "================================="
echo -e " ${Green_font_prefix}欢迎使用 Trojan 一键脚本${Font_color_suffix}"
echo -e " ${Green_font_prefix}作者：${Font_color_suffix}${Red_font_prefix}thNylHx${Font_color_suffix}"
echo -e " ${Green_font_prefix}请保证科学上网已经开启${Font_color_suffix}"
echo -e " ${Green_font_prefix}安装过程中可以按 ctrl+c 强制退出${Font_color_suffix}"
echo -e " ${Red_font_prefix}特别提醒：安装 Trojan 前，建议先申请证书！${Font_color_suffix}"

# 检查Trojan服务状态
check_status() {
    if pgrep -x "trojan-go" > /dev/null; then
        status="running"
    else
        status="stopped"
    fi
}

# 获取当前版本
get_current_version() {
    if [ -f "/root/Trojan/version.txt" ]; then
        cat /root/Trojan/version.txt
    else
        echo "未安装"
    fi
}

# 显示状态
Show_Status() {
    if [ ! -f "$FILE" ]; then
        status="${Red_font_prefix}未安装${Font_color_suffix}"
    else
        check_status
        if [ "$status" == "running" ]; then
            status="${Green_font_prefix}运行中${Font_color_suffix}"
        else
            status="${Red_font_prefix}未运行${Font_color_suffix}"
        fi
    fi

    echo -e " 版本： ${Green_font_prefix}${sh_ver}${Font_color_suffix}"
    echo -e " 状态： ${status}"
}

# 配置文件
Configure() {
    # 端口处理
    read -p "请输入监听端口 (留空以生成随机端口): " PORT
    if [[ -z "$PORT" ]]; then
        PORT=$(shuf -i 10000-65000 -n 1)
        echo -e "随机生成的监听端口: ${Green_font_prefix}$PORT${Font_color_suffix}"
    elif [[ "$PORT" -lt 10000 || "$PORT" -gt 65000 ]]; then
        echo -e "${Red_font_prefix}端口号必须在10000到65000之间。${Font_color_suffix}"
        exit 1
    fi

    # UUID处理
    read -p "请输入 Trojan 密码 (留空以生成随机): " UUID
    if [[ -z "$UUID" ]]; then
        if command -v uuidgen >/dev/null 2>&1; then
            UUID=$(uuidgen)
        else
            UUID=$(cat /proc/sys/kernel/random/uuid)
        fi
        echo -e "随机生成的密码: ${Green_font_prefix}$UUID${Font_color_suffix}"
    fi

    # 获取远程地址
    read -p "请输入远程地址 (输入远程伪装地址): " remote_addr
    if [[ -z "$remote_addr" ]]; then
        remote_addr="192.83.167.78"
    fi

    # 写入配置文件
    cat << EOF > /root/Trojan/config.json
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": $PORT,
    "remote_addr": "$remote_addr",
    "remote_port": 80,
    "password": [
        "$UUID"
    ],
    "ssl": {
        "cert": "/root/Trojan/ssl/server.crt",
        "key": "/root/Trojan/ssl/server.key"
    }
}
EOF

    # 设置为开机自启
    systemctl enable trojan-go
    
    # 重新加载系统服务
    systemctl daemon-reload

    # 启动 Trojan-Go
    systemctl start trojan-go

    # 查看 Trojan-Go 状态
    systemctl status trojan-go
}

# 安装 Trojan
Install() {
    if [ -f "$FILE" ]; then
        echo -e "${Green_font_prefix}Trojan 已经安装。${Font_color_suffix}"
        exit 0
    fi

    echo -e "${Green_font_prefix}安装 Trojan 中...${Font_color_suffix}"
    mkdir -p /root/Trojan
    cd /root/Trojan
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='amd64';;
        'x86' | 'i686' | 'i386')     ARCH='386';;
        'aarch64' | 'arm64') ARCH='arm64-v8';;
        'armv7' | 'armv7l')   ARCH='arm32-v7';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
    esac
    echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"

    VERSION=$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" \
        | grep tag_name \
        | cut -d ":" -f2 \
        | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    echo -e "${Green_font_prefix}获取到的最新版本: ${VERSION}${Font_color_suffix}"

    echo -e "${Green_font_prefix}开始下载 trojan-go${Font_color_suffix}"
    wget -P /root/Trojan "https://github.com/p4gefau1t/trojan-go/releases/download/v${VERSION}/trojan-go-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }

    echo -e "${Green_font_prefix}trojan-go 下载完成, 开始部署${Font_color_suffix}"
    unzip "trojan-go-linux-${ARCH}.zip" && rm "trojan-go-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
    echo "$VERSION" > /root/Trojan/version.txt

    # 系统配置文件
    cat << EOF > /etc/systemd/system/trojan-go.service
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/root/Trojan/trojan-go -config /root/Trojan/config.json
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

    # 提示用户选择配置
    echo -e "${Green_font_prefix}Trojan 安装成功，开始配置配置文件。${Font_color_suffix}"
    Configure
}

# 更新Trojan
Update() {
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}Trojan 未安装，无法更新${Font_color_suffix}"
        exit 1
    fi

    echo -e "${Green_font_prefix}检查 Trojan 更新...${Font_color_suffix}"
    cd /root/Trojan

    current_version=$(get_current_version)
    latest_version=$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    if [[ "$current_version" == "$latest_version" ]]; then
        echo -e "${Green_font_prefix}当前版本: (v${current_version})${Font_color_suffix}"
        echo -e "${Green_font_prefix}最新版本: (v${latest_version})${Font_color_suffix}"
        echo -e "${Green_font_prefix}当前已是最新版本，无需更新！${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}当前版本: ${current_version}${Font_color_suffix}"
        echo -e "${Green_font_prefix}最新版本: ${latest_version}${Font_color_suffix}"
        read -p "是否要更新到最新版本？(y/n): " choice
        case $choice in
            [Yy]* )
                echo -e "${Green_font_prefix}开始更新 Trojan...${Font_color_suffix}"
                ARCH_RAW=$(uname -m)
                case "${ARCH_RAW}" in
                    'x86_64') ARCH='amd64';;
                    'x86' | 'i686' | 'i386') ARCH='386';;
                    'aarch64' | 'arm64') ARCH='arm64-v8';;
                    'armv7' | 'armv7l') ARCH='arm32-v7';;
                    's390x') ARCH='s390x';;
                    *) echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
                esac
                echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"

                echo -e "${Green_font_prefix}开始下载最新版本的 trojan-go${Font_color_suffix}"
                wget -P /root/Trojan "https://github.com/p4gefau1t/trojan-go/releases/download/v${latest_version}/trojan-go-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }

                echo -e "${Green_font_prefix}trojan-go 下载完成，开始部署${Font_color_suffix}"
                unzip -o "trojan-go-linux-${ARCH}.zip" && rm "trojan-go-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
                echo "$latest_version" > /root/Trojan/version.txt

                # 重新加载系统服务
                systemctl daemon-reload

                # 重启 Trojan-Go
                systemctl restart trojan-go

                echo -e "${Green_font_prefix}更新完成，当前版本已更新为 v${latest_version}${Font_color_suffix}"
                ;;
            [Nn]* )
                echo -e "${Red_font_prefix}更新已取消。${Font_color_suffix}"
                ;;
            * )
                echo -e "${Red_font_prefix}无效的输入。${Font_color_suffix}"
                exit 1
                ;;
        esac
    fi
}

# 申请证书
Request_Cert() {
    echo "=============================="
    echo "请选择证书申请方式："
    echo "=============================="
    echo -e " ${Green_font_prefix}1${Font_color_suffix}、 自签证书申请"
    echo -e " ${Green_font_prefix}2${Font_color_suffix}、 Cloudflare 证书申请"
    echo -e " ${Green_font_prefix}3${Font_color_suffix}、 ACME 证书申请"
    echo "=============================="
    read -p "输入数字选择 (1-3): " cert_choice

    case $cert_choice in
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

generate_self_signed_cert() {
    echo -e "${Green_font_prefix}生成自签名证书中...${Font_color_suffix}"
    read -p "请输入伪装域名（例如：example.com）： " DOMAIN
    mkdir -p /root/Trojan/ssl
    openssl req -newkey rsa:2048 -nodes -keyout /root/Trojan/ssl/server.key -x509 -days 365 -out /root/Trojan/ssl/server.crt -subj "/C=CN/ST=Province/L=City/O=Organization/OU=Department/CN=$DOMAIN"
    echo -e "${Green_font_prefix}自签名证书生成完成！${Font_color_suffix}"
}

request_acme_cert() {
    echo -e "${Green_font_prefix}申请 ACME 证书中...${Font_color_suffix}"
    apt-get install -y certbot
    read -p "请输入域名（用于证书申请）： " DOMAIN
    read -p "请输入电子邮件（用于接收通知）： " EMAIL
    certbot certonly --standalone -d "$DOMAIN" -m "$EMAIL" --agree-tos --non-interactive
    cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /root/Trojan/ssl/server.crt
    cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /root/Trojan/ssl/server.key
    echo -e "${Green_font_prefix}ACME 证书申请完成！${Font_color_suffix}"
}

request_cf_cert() {
    echo -e "${Green_font_prefix}申请 Cloudflare 证书中...${Font_color_suffix}"
    read -p "请输入 Cloudflare API Key: " CF_API_KEY
    read -p "请输入 Cloudflare 注册邮箱: " CF_EMAIL
    read -p "请输入域名（用于证书申请）： " DOMAIN
    apt-get install -y curl jq
    cf_zone_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" -H "Authorization: Bearer $CF_API_KEY" -H "Content-Type: application/json" | jq -r '.result[0].id')
    if [ -z "$cf_zone_id" ]; then
        echo -e "${Red_font_prefix}未找到域名的 Zone ID，请检查域名是否正确。${Font_color_suffix}"
        exit 1
    fi
    cert_response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$cf_zone_id/ssl/certificate_packs" \
        -H "Authorization: Bearer $CF_API_KEY" \
        -H "Content-Type: application/json" \
        --data '{"type":"advanced"}')
    cert_id=$(echo "$cert_response" | jq -r '.result.id')
    echo "$cert_id"
    echo -e "${Green_font_prefix}Cloudflare 证书申请完成！${Font_color_suffix}"
}

# 启动 Trojan
Start() {
    echo -e "${Green_font_prefix}启动 Trojan 服务...${Font_color_suffix}"

    # 检查 Trojan 是否已安装
    if [ ! -f "/root/Trojan/trojan-go" ]; then
        echo -e "${Red_font_prefix}Trojan 尚未安装。请先安装 Trojan。${Font_color_suffix}"
        exit 1
    fi

    # 尝试启动服务
    if systemctl start trojan-go; then
        echo -e "${Green_font_prefix}Trojan 服务启动命令已发出。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}启动服务失败。${Font_color_suffix}"
        exit 1
    fi

    # 检查服务状态
    check_status

    # 显示服务状态
    if [ "$status" == "running" ]; then
        echo -e "${Green_font_prefix}Trojan 服务已启动，当前状态: 正在运行${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}Trojan 服务启动失败，当前状态: 未运行${Font_color_suffix}"
    fi
}

# 停止 Trojan
Stop() {
    echo -e "${Green_font_prefix}停止 Trojan 服务...${Font_color_suffix}"

    # 检查 Trojan 是否已安装
    if [ ! -f "/root/Trojan/trojan-go" ]; then
        echo -e "${Red_font_prefix}Trojan 尚未安装。请先安装 Trojan。${Font_color_suffix}"
        exit 1
    fi
    
    # 尝试停止服务
    if systemctl stop trojan-go; then
        echo -e "${Green_font_prefix}Trojan 服务停止命令已发出。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}停止服务失败。${Font_color_suffix}"
        exit 1
    fi

    # 检查服务状态
    check_status

    # 显示服务状态
    if [ "$status" == "stopped" ]; then
        echo -e "${Green_font_prefix}Trojan 服务已停止，当前状态: 未运行${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}Trojan 服务停止失败，当前状态: 正在运行${Font_color_suffix}"
    fi
}

# 重启 Trojan
Restart() {
    echo -e "${Green_font_prefix}重启 Trojan 服务...${Font_color_suffix}"

    # 检查 Trojan 是否已安装
    if [ ! -f "/root/Trojan/trojan-go" ]; then
        echo -e "${Red_font_prefix}Trojan 尚未安装。请先安装 Trojan。${Font_color_suffix}"
        exit 1
    fi
    
    # 尝试重启服务
    if systemctl restart trojan-go; then
        echo -e "${Green_font_prefix}Trojan 服务重启命令已发出。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}重启服务失败。${Font_color_suffix}"
        exit 1
    fi

    # 检查服务状态
    check_status

    # 显示服务状态
    if [ "$status" == "running" ]; then
        echo -e "${Green_font_prefix}Trojan 服务已重启，当前状态: 正在运行${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}Trojan 服务重启失败，当前状态: 未运行${Font_color_suffix}"
    fi
}

# 卸载 Trojan
Uninstall() {
    echo -e "${Red_font_prefix}开始卸载 Trojan...${Font_color_suffix}"

    # 停止 Trojan 服务
    if systemctl is-active --quiet trojan-go; then
        echo -e "${Green_font_prefix}停止 Trojan 服务...${Font_color_suffix}"
        systemctl stop trojan-go || echo -e "${Red_font_prefix}停止服务失败。${Font_color_suffix}"
    else
        echo -e "${Yellow_font_prefix}Trojan 服务未运行。${Font_color_suffix}"
    fi

    # 禁用 Trojan 服务
    if systemctl is-enabled --quiet trojan-go; then
        echo -e "${Green_font_prefix}禁用 Trojan 服务...${Font_color_suffix}"
        systemctl disable trojan-go || echo -e "${Red_font_prefix}禁用服务失败。${Font_color_suffix}"
    else
        echo -e "${Yellow_font_prefix}Trojan 服务已被禁用。${Font_color_suffix}"
    fi

    # 删除 Trojan 目录
    if [ -d "/root/Trojan" ]; then
        echo -e "${Green_font_prefix}删除 Trojan 文件夹...${Font_color_suffix}"
        rm -rf /root/Trojan || echo -e "${Red_font_prefix}删除文件夹失败。${Font_color_suffix}"
    else
        echo -e "${Yellow_font_prefix}Trojan 文件夹不存在。${Font_color_suffix}"
    fi

    # 删除 systemd 服务文件
    if [ -f "/etc/systemd/system/trojan-go.service" ]; then
        echo -e "${Green_font_prefix}删除 systemd 服务文件...${Font_color_suffix}"
        rm /etc/systemd/system/trojan-go.service || echo -e "${Red_font_prefix}删除服务文件失败。${Font_color_suffix}"
    else
        echo -e "${Yellow_font_prefix}systemd 服务文件不存在。${Font_color_suffix}"
    fi

    # 重新加载系统服务
    echo -e "${Green_font_prefix}重新加载 systemd 配置...${Font_color_suffix}"
    systemctl daemon-reload || echo -e "${Red_font_prefix}重新加载配置失败。${Font_color_suffix}"

    echo -e "${Green_font_prefix}卸载完成。${Font_color_suffix}"
}

# 查看已安装的信息
View_Config() {
    if [ -f "/root/Trojan/config.json" ]; then
        echo -e "${Green_font_prefix}当前 Trojan 配置信息：${Font_color_suffix}"
        cat /root/Trojan/config.json
    else
        echo -e "${Red_font_prefix}未找到 Trojan 配置文件。${Font_color_suffix}"
    fi
}

Show_Status() {
    if [ ! -f "$FILE" ]; then
        echo -e " 状态: ${Red_font_prefix}Trojan 未安装${Font_color_suffix}"
    else
        check_status
        if [ "$status" == "running" ]; then
            echo -e " 状态: ${Green_font_prefix}Trojan 运行中${Font_color_suffix}"
        else
            echo -e " 状态: ${Red_font_prefix}Trojan 未运行${Font_color_suffix}"
        fi
    fi
}

# 主菜单
Main() {
    echo "=============================="
    echo -e " 版本：${Green_font_prefix}${sh_ver}${Font_color_suffix}"
    Show_Status
    echo "=============================="
    echo -e " ${Green_font_prefix}1${Font_color_suffix}、 安装 Trojan"
    echo -e " ${Green_font_prefix}2${Font_color_suffix}、 更新 Trojan"
    echo -e " ${Green_font_prefix}3${Font_color_suffix}、 配置 Trojan"
    echo -e " ${Green_font_prefix}4${Font_color_suffix}、 卸载 Trojan"
    echo -e " ${Green_font_prefix}5${Font_color_suffix}、 启动 Trojan"
    echo -e " ${Green_font_prefix}6${Font_color_suffix}、 停止 Trojan"
    echo -e " ${Green_font_prefix}7${Font_color_suffix}、 重启 Trojan"        
    echo -e " ${Green_font_prefix}8${Font_color_suffix}、 查看配置"
    echo -e " ${Green_font_prefix}9${Font_color_suffix}、 申请证书"
    echo -e " ${Green_font_prefix}0${Font_color_suffix}、 退出"
    echo "=============================="
    read -p "请输入数字选择[0-9]: " num

    case "$num" in
        1)
            Install
            ;;
        2)
            Update
            ;;
        3)
            Configure
            ;;
        4)
            Uninstall
            ;;
        5)
            Start
            ;;
        6)
            Stop
            ;;
        7)
            Restart
            ;;
        8)
            View
            ;;
        9)
            Request_Cert
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "${Red_font_prefix}无效的选择，请输入 0 到 9 之间的数字。${Font_color_suffix}"
            ;;
    esac
}

# 启动主菜单
Main
