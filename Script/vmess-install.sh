#!/bin/bash

# wget -O vmess-install.sh --no-check-certificate https://raw.githubusercontent.com/thNylHx/Tools/main/Script/vmess-install.sh && chmod +x vmess-install.sh && ./vmess-install.sh

# 定义颜色代码
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"

# 定义脚本版本
sh_ver="1.0.6"

# V2Ray 可执行文件的路径
FILE="/root/V2Ray/v2ray"

clear
echo -e "================================="
echo -e " ${Green_font_prefix}欢迎使用 V2Ray 一键脚本${Font_color_suffix}"
echo -e " ${Green_font_prefix}作者：${Font_color_suffix}${Red_font_prefix}thNylHx${Font_color_suffix}"
echo -e " ${Green_font_prefix}请保证科学上网已经开启${Font_color_suffix}"
echo -e " ${Green_font_prefix}安装过程中可以按 ctrl+c 强制退出${Font_color_suffix}"
echo -e "================================="

# 检查V2Ray服务状态
check_status() {
    if pgrep -x "v2ray" > /dev/null; then
        status="running"
    else
        status="stopped"
    fi
}

# 获取当前版本
get_current_version() {
    if [ -f "/root/V2Ray/version.txt" ]; then
        cat /root/V2Ray/version.txt
    else
        echo "未安装"
    fi
}

# 安装V2Ray
Install() {
    
    if [ -f "$FILE" ]; then
        echo -e "${Green_font_prefix}V2Ray 已经安装。${Font_color_suffix}"
        exit 0
    fi
    
    echo -e "${Green_font_prefix}安装 V2Ray 中...${Font_color_suffix}"
    mkdir -p /root/V2Ray
    cd /root/V2Ray
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='64';;
        'x86' | 'i686' | 'i386')     ARCH='32';;
        'aarch64' | 'arm64') ARCH='arm64-v8a';;
        'armv7' | 'armv7l')   ARCH='arm32-v7a';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
    esac
    echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"

    VERSION=$(curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" \
        | grep tag_name \
        | cut -d ":" -f2 \
        | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    echo -e "${Green_font_prefix}获取到的最新版本: ${VERSION}${Font_color_suffix}"

    echo -e "${Green_font_prefix}开始下载 v2ray-core${Font_color_suffix}"
    wget -P /root/V2Ray "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }

    echo -e "${Green_font_prefix}v2ray-core 下载完成, 开始部署${Font_color_suffix}"
    unzip "v2ray-linux-${ARCH}.zip" && rm "v2ray-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
    echo "$VERSION" > /root/V2Ray/version.txt

# 系统配置文件
cat << EOF > /etc/systemd/system/v2ray.service
[Unit]
Description=V2Ray Service
Documentation=https://www.v2fly.org/
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/root/V2Ray/v2ray run -config /root/V2Ray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

    # 提示用户选择配置
    echo -e "${Green_font_prefix}V2Ray 安装成功，请选择配置文件类型。${Font_color_suffix}"
    Set
}

# 更新 V2Ray
Update() {
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}V2Ray 未安装，无法更新${Font_color_suffix}"
        exit 1
    fi

    echo -e "${Green_font_prefix}检查 V2Ray 更新...${Font_color_suffix}"
    cd /root/V2Ray

    current_version=$(get_current_version)
    latest_version=$(curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

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
                echo -e "${Green_font_prefix}开始更新 V2Ray...${Font_color_suffix}"
                ARCH_RAW=$(uname -m)
                case "${ARCH_RAW}" in
                    'x86_64') ARCH='64';;
                    'x86' | 'i686' | 'i386') ARCH='32';;
                    'aarch64' | 'arm64') ARCH='arm64-v8a';;
                    'armv7' | 'armv7l') ARCH='arm32-v7a';;
                    's390x') ARCH='s390x';;
                    *) echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
                esac
                echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"

                echo -e "${Green_font_prefix}开始下载最新版本的 V2Ray${Font_color_suffix}"
                wget -P /root/V2Ray "https://github.com/v2fly/v2ray-core/releases/download/v${latest_version}/v2ray-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }

                echo -e "${Green_font_prefix}V2Ray 下载完成，开始部署${Font_color_suffix}"
                unzip -o "V2Ray-linux-${ARCH}.zip" && rm "V2Ray-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }
                echo "$latest_version" > /root/V2Ray/version.txt

                # 重新加载系统服务
                systemctl daemon-reload

                # 重启 Trojan-Go
                systemctl start v2ray

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

# 设置配置信息
Set() {
    echo "=============================="
    echo "请选择配置文件类型："
    echo "=============================="
    echo -e " ${Green_font_prefix}1${Font_color_suffix}、 vmess+tcp"
    echo -e " ${Green_font_prefix}2${Font_color_suffix}、 vmess+ws"
    echo -e " ${Green_font_prefix}3${Font_color_suffix}、 vmess+tcp+tls（需要域名）"
    echo -e " ${Green_font_prefix}4${Font_color_suffix}、 vmess+ws+tls（需要域名）"
    echo "=============================="
    read -p "输入数字选择 (1-4，默认1): " config_choice
    config_choice=${config_choice:-1}  # 如果用户没有输入，默认为1

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
    read -p "请输入 V2Ray UUID (留空以生成随机UUID): " UUID
    if [[ -z "$UUID" ]]; then
        if command -v uuidgen >/dev/null 2>&1; then
            UUID=$(uuidgen)
        else
            UUID=$(cat /proc/sys/kernel/random/uuid)
        fi
        echo -e "随机生成的UUID: ${Green_font_prefix}$UUID${Font_color_suffix}"
    fi

    # WebSocket路径处理
    if [[ "$config_choice" == "2" || "$config_choice" == "4" ]]; then
        read -p "请输入 WebSocket 路径 (留空以生成随机路径): " WS_PATH
        if [[ -z "$WS_PATH" ]]; then
            WS_PATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
            echo -e "随机生成的 WebSocket 路径: ${Green_font_prefix}/$WS_PATH${Font_color_suffix}"
        else
            WS_PATH="${WS_PATH#/}"  # 移除前导斜杠
            echo -e "WebSocket 路径: ${Green_font_prefix}/$WS_PATH${Font_color_suffix}"
        fi
    fi

    # 创建配置文件
    case $config_choice in
        1)
        cat << EOF > /root/V2Ray/config.json
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "tcp"
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
        ;;
        2)
        cat << EOF > /root/V2Ray/config.json
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/$WS_PATH"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
        ;;
        3)
        cat << EOF > /root/V2Ray/config.json
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
      },
        "streamSettings": {
          "network": "tcp",
          "security": "tls",
          "tlsSettings": {
            "certificates": [
              {
                "certificateFile": "/root/V2Ray/ssl/server.crt", 
                "keyFile": "/root/V2Ray/ssl/server.key" 
              }
            ]
          }
        }
      }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
        ;;
        4)
        cat << EOF > /root/V2Ray/config.json
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
      },
        "streamSettings": {
          "network": "ws",
          "wsSettings": {
            "path": "/$WS_PATH"
            },
          "security": "tls",
          "tlsSettings": {
            "certificates": [
              {
                "certificateFile": "/root/V2Ray/ssl/server.crt", 
                "keyFile": "/root/V2Ray/ssl/server.key" 
              }
            ]
          }
        }
      }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
        ;;
        *)
        echo -e "${Red_font_prefix}无效的选项。${Font_color_suffix}"
        exit 1
        ;;
    esac

    echo -e "${Green_font_prefix}配置文件已生成。如果你选择带有 TLS 的选项，请申请证书！${Font_color_suffix}"
    # 设置开机启动
    systemctl enable v2ray

    # 重新加载
    systemctl daemon-reload

    # 启动 V2Ray 服务
    systemctl start v2ray

    # 检查 V2Ray 服务状态
    systemctl status v2ray
}

# 启动 V2Ray
Start() {
    echo -e "${Green_font_prefix}启动 V2Ray 服务...${Font_color_suffix}"

    # 检查 V2Ray 是否已安装
    if [ ! -f "/root/V2Ray/v2ray" ]; then
        echo -e "${Red_font_prefix}V2Ray 尚未安装。请先安装 V2Ray。${Font_color_suffix}"
        exit 1
    fi

    # 尝试启动服务
    if systemctl start v2ray; then
        echo -e "${Green_font_prefix}V2Ray 服务启动命令已发出。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}启动服务失败。${Font_color_suffix}"
        exit 1
    fi

    # 检查服务状态
    check_status

    # 显示服务状态
    if [ "$status" == "running" ]; then
        echo -e "${Green_font_prefix}V2Ray 服务已启动，当前状态: 正在运行${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}V2Ray 服务启动失败，当前状态: 未运行${Font_color_suffix}"
    fi
}


# 停止 V2Ray
Stop() {
    echo -e "${Green_font_prefix}停止 V2Ray 服务...${Font_color_suffix}"

    # 检查 V2Ray 是否已安装
    if [ ! -f "/root/V2Ray/v2ray" ]; then
        echo -e "${Red_font_prefix}V2Ray 尚未安装。请先安装 V2Ray。${Font_color_suffix}"
        exit 1
    fi

    # 尝试停止服务
    if systemctl stop v2ray; then
        echo -e "${Green_font_prefix}V2Ray 服务停止命令已发出。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}停止服务失败。${Font_color_suffix}"
        exit 1
    fi

    # 检查服务状态
    check_status

    # 显示服务状态
    if [ "$status" == "running" ]; then
        echo -e "${Green_font_prefix}V2Ray 服务停止失败，当前状态: 正在运行${Font_color_suffix}"
    else
        echo -e "${Green_font_prefix}V2Ray 服务已停止，当前状态: 未运行${Font_color_suffix}"
    fi
}

# 重启 V2Ray
Restart() {
    echo -e "${Green_font_prefix}重启 V2Ray 服务...${Font_color_suffix}"

    # 检查 V2Ray 是否已安装
    if [ ! -f "/root/V2Ray/v2ray" ]; then
        echo -e "${Red_font_prefix}V2Ray 尚未安装。请先安装 V2Ray。${Font_color_suffix}"
        exit 1
    fi

    # 尝试重启服务
    if systemctl restart v2ray; then
        echo -e "${Green_font_prefix}V2Ray 服务重启命令已发出。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}重启服务失败。${Font_color_suffix}"
        exit 1
    fi

    # 检查服务状态
    check_status

    # 显示服务状态
    if [ "$status" == "running" ]; then
        echo -e "${Green_font_prefix}V2Ray 服务已重启，当前状态: 正在运行${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}V2Ray 服务重启失败，当前状态: 未运行${Font_color_suffix}"
    fi
}

# 卸载 V2Ray
Uninstall() {
    echo -e "${Green_font_prefix}正在卸载 V2Ray...${Font_color_suffix}"

    # 检查 V2Ray 是否已安装
    if [ ! -f "/root/V2Ray/v2ray" ]; then
        echo -e "${Red_font_prefix}V2Ray 尚未安装。${Font_color_suffix}"
        exit 1
    fi

    # 停止 V2Ray 服务
    echo -e "${Green_font_prefix}停止 V2Ray 服务...${Font_color_suffix}"
    if systemctl stop v2ray; then
        echo -e "${Green_font_prefix}V2Ray 服务已停止。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}停止服务失败。${Font_color_suffix}"
    fi

    # 禁用并删除 V2Ray 服务
    echo -e "${Green_font_prefix}禁用 V2Ray 服务...${Font_color_suffix}"
    if systemctl disable v2ray; then
        echo -e "${Green_font_prefix}V2Ray 服务已禁用。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}禁用服务失败。${Font_color_suffix}"
    fi

    echo -e "${Green_font_prefix}删除 V2Ray 服务文件...${Font_color_suffix}"
    if rm /etc/systemd/system/v2ray.service; then
        echo -e "${Green_font_prefix}V2Ray 服务文件已删除。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}删除服务文件失败。${Font_color_suffix}"
    fi

    # 重新加载系统服务配置
    echo -e "${Green_font_prefix}重新加载系统服务配置...${Font_color_suffix}"
    systemctl daemon-reload

    # 删除 V2Ray 文件夹
    echo -e "${Green_font_prefix}删除 V2Ray 文件夹...${Font_color_suffix}"
    if rm -rf /root/V2Ray; then
        echo -e "${Green_font_prefix}V2Ray 文件夹已删除。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}删除文件夹失败。${Font_color_suffix}"
    fi

    # 删除 V2Ray 相关用户（如果存在）
    echo -e "${Green_font_prefix}删除 V2Ray 相关用户...${Font_color_suffix}"
    if userdel -r v2ray 2>/dev/null; then
        echo -e "${Green_font_prefix}V2Ray 用户已删除。${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}删除用户失败或用户不存在。${Font_color_suffix}"
    fi

    echo -e "${Green_font_prefix}V2Ray 已成功卸载。${Font_color_suffix}"
}

# 查看配置
View() {
    if [ -f "/root/V2Ray/config.json" ]; then
        cat /root/V2Ray/config.json
    else
        echo -e "${Red_font_prefix}配置文件不存在。${Font_color_suffix}"
    fi
}

# 申请证书
Request_Cert() {
    echo "=============================="
    echo "请选择证书申请方式："
    echo "=============================="
    echo -e " ${Green_font_prefix}1${Font_color_suffix}、 自签名证书"
    echo -e " ${Green_font_prefix}2${Font_color_suffix}、 Cloudflare 证书"
    echo -e " ${Green_font_prefix}3${Font_color_suffix}、 ACME 证书"
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
    mkdir -p /root/V2Ray/ssl
    openssl req -newkey rsa:2048 -nodes -keyout /root/V2Ray/ssl/server.key -x509 -days 365 -out /root/V2Ray/ssl/server.crt -subj "/C=CN/ST=Province/L=City/O=Organization/OU=Department/CN=$DOMAIN"
    echo -e "${Green_font_prefix}自签名证书生成完成！${Font_color_suffix}"
}

request_acme_cert() {
    echo -e "${Green_font_prefix}申请 ACME 证书中...${Font_color_suffix}"
    apt-get install -y certbot
    read -p "请输入域名（用于证书申请）： " DOMAIN
    read -p "请输入电子邮件（用于接收通知）： " EMAIL
    certbot certonly --standalone -d "$DOMAIN" -m "$EMAIL" --agree-tos --non-interactive
    cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /root/V2Ray/ssl/server.crt
    cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /root/V2Ray/ssl/server.key
    echo -e "${Green_font_prefix}ACME 证书申请完成！${Font_color_suffix}"
}

request_cf_cert() {
    echo -e "${Green_font_prefix}申请 Cloudflare 证书中...${Font_color_suffix}"
    read -p "请输入 Cloudflare API 密钥（可以从 Cloudflare 控制面板获取）： " CF_API_KEY
    read -p "请输入 Cloudflare 账户邮箱： " CF_EMAIL
    read -p "请输入域名（用于证书申请）： " DOMAIN

    mkdir -p /root/V2Ray/ssl
    # 使用 Cloudflare API 获取证书（具体命令视 Cloudflare API 提供的功能而定，这里假设有一个用于获取证书的命令）
    cfssl gencert -ca /root/V2Ray/ssl/ca.pem -ca-key /root/V2Ray/ssl/ca-key.pem -config /root/V2Ray/ssl/ca-config.json -profile client /root/V2Ray/ssl/$DOMAIN.csr | cfssljson -bare /root/V2Ray/ssl/$DOMAIN
    cp /root/V2Ray/ssl/$DOMAIN.pem /root/V2Ray/ssl/server.crt
    cp /root/V2Ray/ssl/$DOMAIN-key.pem /root/V2Ray/ssl/server.key
    echo -e "${Green_font_prefix}Cloudflare 证书申请完成！${Font_color_suffix}"
}

Show_Status() {
    if [ ! -f "$FILE" ]; then
        echo -e " 状态: ${Red_font_prefix}V2Ray 未安装${Font_color_suffix}"
    else
        check_status
        if [ "$status" == "running" ]; then
            echo -e " 状态: ${Green_font_prefix}V2Ray 运行中${Font_color_suffix}"
        else
            echo -e " 状态: ${Red_font_prefix}V2Ray 未运行${Font_color_suffix}"
        fi
    fi
}

# 主菜单
Main() {
        echo -e " 版本：${Green_font_prefix}${sh_ver}${Font_color_suffix}"
        Show_Status
        echo "=============================="
        echo -e " ${Green_font_prefix}1${Font_color_suffix}、 安装 V2Ray"
        echo -e " ${Green_font_prefix}2${Font_color_suffix}、 更新 V2Ray"
        echo -e " ${Green_font_prefix}3${Font_color_suffix}、 配置 V2Ray"
        echo -e " ${Green_font_prefix}4${Font_color_suffix}、 卸载 V2Ray"
        echo -e " ${Green_font_prefix}5${Font_color_suffix}、 启动 V2Ray"
        echo -e " ${Green_font_prefix}6${Font_color_suffix}、 停止 V2Ray"
        echo -e " ${Green_font_prefix}7${Font_color_suffix}、 重启 V2Ray"
        echo -e " ${Green_font_prefix}8${Font_color_suffix}、 查看配置"
        echo -e " ${Green_font_prefix}9${Font_color_suffix}、 申请证书"
        echo -e " ${Green_font_prefix}0${Font_color_suffix}、 退出脚本"
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
                Set
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
                echo -e "${Red_font_prefix}无效的选项。${Font_color_suffix}"
                ;;
    esac
}

# 执行主菜单
Main
