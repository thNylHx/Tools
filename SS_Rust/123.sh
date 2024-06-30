#!/bin/bash

## bash <(curl -fsSL https://raw.githubusercontent.com/cooip-jm/About-openwrt/main/mihomo-deb-install.sh)

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
echo  "当前设备架构: ${ARCH_RAW}"

VERSION=$(curl -L "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt" || { echo "Failed to fetch version"; exit 1; })

echo  "获取到的版本: ${VERSION}"

wget "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-${ARCH}-compatible-${VERSION}.gz"
echo "${VERSION}下载完成, 开始部署"

echo "开始创建 mihomo 文件夹"
# 创建 mihomo 文件夹
mkdir -p /root/mihomo
echo "开始加压 mihomo "
# 解压
gzip -d mihomo-linux-amd64-compatible-${VERSION}.gz
echo "开始授权 mihomo "
# 授权
chmod 777 mihomo-linux-amd64-compatible-${VERSION}
echo "开始移动 mihomo "
# 移动
mv mihomo-linux-amd64-compatible-${VERSION} /root/mihomo/mihomo
echo "开始安装 mihomo UI "
# 安装UI
git clone https://github.com/metacubex/metacubexd.git -b gh-pages /root/mihomo/ui
echo "开始系统服务 "
# 安装服务
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
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF

echo "安装完成，上传你的config.ymal 文件 就可以使用"
