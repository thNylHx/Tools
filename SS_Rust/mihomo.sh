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
VERSION=$(echo $RESPONSE | grep -oP '"name":\s*"\K[^"]+' | head -1)

if [ -z "$VERSION" ]; then
    echo "未能获取最新版本"
    exit 1
fi

echo "获取到的最新版本: ${VERSION}"

# 获取下载链接
DOWNLOAD_URL=$(echo $RESPONSE | grep -oP "https://github.com/SagerNet/mihomo/releases/download/$VERSION/mihomo-linux-${ARCH}-compatible-alpha-[^\" ]+.gz" | head -1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "未能获取下载链接"
    exit 1
fi

echo "下载链接: ${DOWNLOAD_URL}"

# 创建 mihomo 文件夹
mkdir -p /root/mihomo

# 下载并解压 mihomo
wget -O /root/mihomo/mihomo.gz "$DOWNLOAD_URL"

gunzip /root/mihomo/mihomo.gz

echo "下载并解压完成"

# 后续操作，例如运行 mihomo
# /root/mihomo/mihomo
