#!/bin/bash

## bash <(curl -fsSL https://raw.githubusercontent.com/thNylHx/Tools/main/Script/vmess-install.sh)

set -e -o pipefail

ARCH_RAW=$(uname -m)
case "${ARCH_RAW}" in
    'x86_64')    ARCH='64';;
    'x86' | 'i686' | 'i386')     ARCH='86';;
    'aarch64' | 'arm64') ARCH='arm64';;
    'armv7l')   ARCH='armv7';;
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

# 根据设备架构下载对应的版本
wget "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip"

echo "v2ray-core 下载完成, 开始部署"
