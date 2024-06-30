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

# 下载并解压 mihomo
wget -O /root/mihomo.gz "$DOWNLOAD_URL"
gunzip /root/mihomo.gz

# 创建 mihomo 文件夹
mkdir -p /root/mihomo

# 获取下载的文件名并重命名为 mihomo
mv /root/mihomo /root/mihomo/mihomo

# 授权最高权限
chmod 777 /root/mihomo/mihomo

echo "下载并解压完成"

# 后续操作，例如运行 mihomo
# /root/mihomo/mihomo
