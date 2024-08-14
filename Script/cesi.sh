#!/bin/bash

set -e -o pipefail

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo "请以 root 权限运行此脚本。" 
   exit 1
fi

# 检查 V2ray 服务状态
check_v2ray_status() {
    if systemctl is-active --quiet v2ray; then
        echo "V2ray 服务正在运行。"
    else
        echo "V2ray 服务未运行。"
    fi
}

# 检查 V2ray 是否设置为开机启动
check_v2ray_enable() {
    if systemctl is-enabled --quiet v2ray; then
        echo "V2ray 已设置为开机启动。"
    else
        echo "V2ray 未设置为开机启动。"
    fi
}

echo "V2ray 一键安装管理脚本"
echo "请选择操作："
echo "=============================="
echo " 1、 安装 V2ray"
echo " 2、 升级 V2ray"
echo " 3、 卸载 V2ray"
echo "=============================="
echo " 4、 重新启动 V2ray"
echo " 5、 重新加载 V2ray"
echo " 6、 设置开机启动 V2ray"
echo " 7、 查看 V2ray 启动状态"
echo " 8、 查看 V2ray 开机启动设置"
echo "=============================="
echo " 0、 退出一键安装脚本"
read -p "输入数字选择 [0-8]: " action

case $action in
    1)
    echo "开始安装 V2ray，请稍后..."
    mkdir -p /root/V2ray
    cd /root/V2ray

    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='64';;
        'x86' | 'i686' | 'i386')     ARCH='32';;
        'aarch64' | 'arm64') ARCH='arm64-v8a';;
        'armv7' | 'armv7l')   ARCH='arm32-v7a';;
        's390x')    ARCH='s390x';;
        *)          echo "不支持的架构: ${ARCH_RAW}"; exit 1;;
    esac
    echo "当前设备架构: ${ARCH_RAW}"

    VERSION=$(curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" \
        | grep tag_name \
        | cut -d ":" -f2 \
        | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    echo "获取到的最新版本: ${VERSION}"

    echo "开始下载 v2ray-core"

    wget -P /root/V2ray "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip" || { echo "下载失败"; exit 1; }

    echo "v2ray-core 下载完成, 开始部署"

    unzip "v2ray-linux-${ARCH}.zip" && rm "v2ray-linux-${ARCH}.zip" || { echo "解压失败"; exit 1; }

    echo "配置 V2ray"

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
ExecStart=/root/V2ray/v2ray run -config /root/V2ray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

    echo "请选择配置文件类型："
    echo "=============================="
    echo " 1、 vmess+tcp"
    echo " 2、 vmess+ws"
    echo " 3、 vmess+tcp+tls（需要域名）"
    echo " 4、 vmess+ws+tls（需要域名）"
    echo "=============================="
    read -p "输入数字选择 (1-4): " config_choice

    # 端口处理
    read -p "请输入监听端口 (10000-65000之间, 留空以生成随机端口): " PORT
    if [[ -z "$PORT" ]]; then
        PORT=$(shuf -i 10000-65000 -n 1)
        echo "随机生成的监听端口: $PORT"
    fi

    # UUID处理
    read -p "请输入 V2Ray UUID (留空以生成随机UUID): " UUID
    if [[ -z "$UUID" ]]; then
        if command -v uuidgen >/dev/null 2>&1; then
            UUID=$(uuidgen)
        else
            UUID=$(cat /proc/sys/kernel/random/uuid)
        fi
        echo "随机生成的UUID: $UUID"
    fi

    # WebSocket 路径处理
    if [[ $config_choice == 2 || $config_choice == 4 ]]; then
        read -p "请输入 WebSocket 路径（例如 /v2ray，留空以生成随机路径）: " WS_PATH
        if [[ -z "$WS_PATH" ]]; then
            WS_PATH=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
            echo "生成的 WebSocket 路径: /${WS_PATH}"
            WS_PATH="/${WS_PATH}"
        fi
    fi

    case $config_choice in
        1)
        cat << EOF > /root/V2ray/config.json
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
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",  
      "settings": {}
    }
  ],
  "vmess-aead": true
}
EOF
        ;;
        2)
        cat << EOF > /root/V2ray/config.json
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
          "path": "$WS_PATH"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ],
  "vmess-aead": true
}
EOF
        ;;
        3)
        if [[ ! -f /root/V2ray/server.crt || ! -f /root/V2ray/server.key ]]; then
            echo "TLS 配置文件 server.crt 或 server.key 不存在，请先生成或上传证书文件。"
            exit 1
        fi

        cat << EOF > /root/V2ray/config.json
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
              "certificateFile": "/root/V2ray/server.crt", 
              "keyFile": "/root/V2ray/server.key" 
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
  ],
  "vmess-aead": true
}
EOF
        ;;
        4)
        if [[ ! -f /root/V2ray/server.crt || ! -f /root/V2ray/server.key ]]; then
            echo "TLS 配置文件 server.crt 或 server.key 不存在，请先生成或上传证书文件。"
            exit 1
        fi

        cat << EOF > /root/V2ray/config.json
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
          "path": "$WS_PATH"
        },
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/root/V2ray/server.crt", 
              "keyFile": "/root/V2ray/server.key" 
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
  ],
  "vmess-aead": true
}
EOF
    esac

    echo "V2ray 安装完成"
    systemctl daemon-reload
    systemctl start v2ray
    ;;

    2)
    echo "开始升级 V2ray"

    # 停止现有的 V2ray 服务
    systemctl stop v2ray

    # 获取当前系统架构
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='64';;
        'x86' | 'i686' | 'i386')     ARCH='32';;
        'aarch64' | 'arm64') ARCH='arm64-v8a';;
        'armv7' | 'armv7l')   ARCH='arm32-v7a';;
        's390x')    ARCH='s390x';;
        *)          echo "不支持的架构: ${ARCH_RAW}"; exit 1;;
    esac

    echo "当前设备架构: ${ARCH_RAW}"

    # 获取最新版本
    VERSION=$(curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" \
        | grep tag_name \
        | cut -d ":" -f2 \
        | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    echo "获取到的最新版本: ${VERSION}"

    echo "开始下载 v2ray-core"

    wget -P /root/V2ray "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip"

    echo "v2ray-core 下载完成, 开始部署"

    unzip -o "v2ray-linux-${ARCH}.zip" && rm "v2ray-linux-${ARCH}.zip"

    echo "V2ray 升级完成"
    systemctl daemon-reload
    systemctl start v2ray
    ;;

    3)
    echo "开始卸载 V2ray"

    # 停止服务
    systemctl stop v2ray

    # 删除服务文件和二进制文件
    systemctl disable v2ray
    rm -f /etc/systemd/system/v2ray.service
    rm -rf /root/V2ray

    echo "V2ray 卸载完成"
    ;;

    4)
    echo "重新启动 V2ray"
    systemctl restart v2ray
    ;;

    5)
    echo "重新加载 V2ray 配置"
    systemctl reload v2ray
    ;;

    6)
    echo "设置 V2ray 开机启动"
    systemctl enable v2ray
    ;;

    7)
    echo "查看 V2ray 启动状态"
    check_v2ray_status
    ;;

    8)
    echo "查看 V2ray 开机启动设置"
    check_v2ray_enable
    ;;

    0)
    echo "退出脚本"
    exit 0
    ;;

    *)
    echo "无效选项"
    exit 1
    ;;
esac
