#!/bin/bash

## bash <(curl -fsSL https://raw.githubusercontent.com/thNylHx/Tools/main/Script/vmess-install.sh)

set -e -o pipefail

echo "开始创建 V2ray 文件夹"
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

# 根据设备架构下载对应的版本到指定文件夹
wget -P /root/V2ray "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip"

echo "v2ray-core 下载完成, 开始部署"

echo "解压 V2ray"

# 使用 ${ARCH} 来匹配正确的文件名
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

echo "服务端配置文件 vmess+tcp"

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

echo "V2ray 部署完成"
