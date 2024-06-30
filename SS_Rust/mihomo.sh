#!/bin/bash

set -e -o pipefail

ARCH_RAW=$(uname -m)
case "${ARCH_RAW}" in
    'x86_64')    ARCH='amd64';;
    'x86' | 'i686' | 'i386')     ARCH='386';;
    'aarch64' | 'arm64') ARCH='arm64';;
    'armv7l')   ARCH='armv7';;
    's390x')    ARCH='s390x';;
    *)          echo "Unsupported architecture: ${ARCH_RAW}"; exit 1;;
esac

echo "当前设备架构: ${ARCH_RAW}"

# 获取最新版本
RESPONSE=$(curl -s "https://api.github.com/repos/MetaCubeX/mihomo/releases?per_page=1&page=0")

# 获取下载链接并解析版本号
DOWNLOAD_URL=$(echo $RESPONSE | grep -oP "https://github.com/MetaCubeX/mihomo/releases/download/[^/]+/mihomo-linux-${ARCH}-compatible-alpha-[^\" ]+.gz" | head -1)
VERSION=$(echo $DOWNLOAD_URL | grep -oP "alpha-\K[^-]+(?=.gz)")

if [ -z "$VERSION" ]; then
    echo "未能获取最新版本"
    exit 1
fi

echo "获取到的最新版本: ${VERSION}"
echo "下载链接: ${DOWNLOAD_URL}"

# 创建 mihomo 文件夹
mkdir -p /root/mihomo

# 下载并解压 mihomo
wget -O /root/mihomo/mihomo.gz "$DOWNLOAD_URL"
gunzip /root/mihomo/mihomo.gz

# 获取下载的文件名并重命名为 mihomo
DOWNLOADED_FILE=$(basename ${DOWNLOAD_URL%.gz})
mv /root/mihomo/$DOWNLOADED_FILE /root/mihomo/mihomo

# 授权最高权限
chmod 777 /root/mihomo/mihomo

# 安装UI
git clone https://github.com/metacubex/metacubexd.git -b gh-pages /root/mihomo/ui

# 创建 systemd 配置文件
cat << EOF > /etc/systemd/system/mihomo.service
[Unit]
Description=mihomo Daemon, Another Clash Kernel.
After=network.target NetworkManager.service systemd-networkd.service iwd.service

[Service]
Type=simple
LimitNPROC=500
LimitNOFILE=1000000
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
Restart=always
ExecStartPre=/usr/bin/sleep 1s
ExecStart=/root/mihomo/mihomo -d /root/mihomo
ExecReload=/bin/kill -HUP \$MAINPID

[Install]
WantedBy=multi-user.target
EOF

# 启用和启动 mihomo 服务
systemctl enable mihomo.service
systemctl start mihomo.service

# 完成
echo "安装和配置完成，上传config.ymal文件到root/mihomo文件夹下就可以使用了"
