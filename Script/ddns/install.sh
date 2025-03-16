#!/bin/bash

#!name = ddns-go 一键脚本 Beta 加速版
#!desc = 支持，安装、更新、卸载等
#!date = 2024-11-04 18:50
#!author = ChatGPT

# bash <(wget -qO- --no-check-certificate https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Script/ddns_go/install.sh)

set -e -o pipefail

# 更新系统
apt update && apt dist-upgrade -y

# 安装插件
apt-get install curl unzip git wget -y

mkdir -p /root/ddns && cd /root/ddns

ARCH_RAW=$(uname -m)
case "${ARCH_RAW}" in
    'x86_64')    ARCH='x86_64';;
    'aarch64' | 'arm64') ARCH='arm64';;
    'armv7l')   ARCH='armv7';;
    *)          echo -e "${Red}不支持的架构：${ARCH_RAW}${Reset}"; exit 1;;
esac
echo "当前架构: ${ARCH_RAW}"

VERSION_URL="https://api.github.com/repos/jeessy2/ddns-go/releases/latest"
VERSION=$(curl -sSL "$VERSION_URL" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//' || { echo -e "${Red}获取版本信息失败${Reset}"; exit 1; })
echo  "获取到的版本: ${VERSION}"

case "$ARCH" in
    'arm64' | 'armv7' | 'x86_64') FILENAME="ddns-go_${VERSION}_linux_${ARCH}.tar.gz";;
    *)       echo -e "不支持的架构: ${ARCH}${Reset}"; exit 1;;
esac

DOWNLOAD_URL="https://github.com/jeessy2/ddns-go/releases/download/v${VERSION}/${FILENAME}"
wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red}下载失败${Reset}"; exit 1; }
tar -xzvf "$FILENAME" && rm -f "$FILENAME" || { echo -e "${Red}解压失败${Reset}"; exit 1; }
chmod +x ddns-go

./ddns-go -s install -c /root/ddns/.ddns_go_config.yaml
