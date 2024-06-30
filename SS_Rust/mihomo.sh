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
echo  "当前设备架构${ARCH_RAW}"

VERSION=$(curl -s "https://api.github.com/repos/MetaCubeX/mihomo/releases?per_page=1&page=0" \
    | grep tag_name \
    | cut -d ":" -f2 \
    | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

echo  "获取到的版本:${VERSION}"
#ARCH

wget "https://github.com/SagerNet/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-${ARCH}-compatible-alpha-${VERSION}.gz"

# 创建 mihomo 文件夹
mkdir -p /root/mihomo

# 解压文件
gzip -d mihomo-linux-${ARCH}-compatible-${VERSION}.gz

# 授权最高权限
chmod 777 mihomo-linux-${ARCH}-compatible-${VERSION}

# 重命名并移动到 /root/mihomo/
mv mihomo-linux-${ARCH}-compatible-${VERSION} /root/mihomo/mihomo

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
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl restart mihomo
echo "重启服务完成"
