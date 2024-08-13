#!/bin/bash

## bash <(curl -fsSL https://raw.githubusercontent.com/thNylHx/Tools/main/Script/vmess-install.sh)

set -e -o pipefail

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo "请以 root 权限运行此脚本。" 
   exit 1
fi

echo "V2ray 一键安装管理脚本"
echo "请选择操作："
——————————————————————————————————
echo " 1、 安装 V2ray"
echo " 2、 升级 V2ray"
echo " 3、 卸载 V2ray"
——————————————————————————————————
read -p "输入数字选择 (1/2/3): " action

case $action in
    1)
    echo "开始安装 V2ray"
    
    echo "创建 V2ray 文件夹"
    mkdir -p /root/V2ray
    
    cd /root/V2ray
    echo "创建完成"

    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='64';;
        'x86' | 'i686' | 'i386')     ARCH='32';;
        'aarch64' | 'arm64') ARCH='arm64-v8a';;
        'armv7' | 'armv7l')   ARCH='arm32-v7a';;
        's390x')    ARCH='s390x';;
        *)          echo "Unsupported architecture: ${ARCH_RAW}"; exit 1;;
    esac
    echo "当前设备架构: ${ARCH_RAW}"

    VERSION=$(curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" \
        | grep tag_name \
        | cut -d ":" -f2 \
        | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    echo "获取到的最新版本: ${VERSION}"

    echo "开始下载 v2ray-core"

    wget -P /root/V2ray "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip"

    echo "v2ray-core 下载完成, 开始部署"

    unzip "v2ray-linux-${ARCH}.zip" && rm "v2ray-linux-${ARCH}.zip"

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
    ——————————————————————————————————
    echo " 1、 vmess+tcp"
    echo " 2、 vmess+ws"
    echo " 3、 vmess+tcp+tls（需要域名）"
    echo " 4、 vmess+ws+tls（需要域名）"
    ——————————————————————————————————
    read -p "输入数字选择 (1/2/3/4): " config_choice

    case $config_choice in
        1)
        cat << EOF > /root/V2ray/config.json
{
  "inbounds": [
    {
      "port": 443, 
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "af41686b-cb85-494a-a554-eeaa1514bca7",  
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
      "port": 443, 
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "af41686b-cb85-494a-a554-eeaa1514bca7",  
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/v2ray"
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
        cat << EOF > /root/V2ray/config.json
{
  "inbounds": [
    {
      "port": 443, 
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "af41686b-cb85-494a-a554-eeaa1514bca7",  
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
        cat << EOF > /root/V2ray/config.json
{
  "inbounds": [
    {
      "port": 443, 
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "af41686b-cb85-494a-a554-eeaa1514bca7",  
            "alterId": 0
          }
        ]
      },
        "streamSettings": {
          "network": "ws",
          "wsSettings": {
            "path": "/v2ray"
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
        ;;
        *)
        echo "无效选择，退出安装"
        exit 1
        ;;
    esac

    echo "V2ray 安装完成"
    systemctl daemon-reload

    systemctl start v2ray
    ;;

    2)
    echo "开始升级 V2ray"

    # 停止现有的 V2ray 服务
    systemctl stop v2ray

    # 删除旧文件
    rm -rf /root/V2ray

    # 重新执行安装流程
    $0 1

    echo "V2ray 升级完成"
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

    *)
    echo "无效选择，退出脚本"
    exit 1
    ;;
esac
