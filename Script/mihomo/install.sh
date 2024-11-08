#!/bin/bash

#!name = mihomo 一键安装脚本
#!desc = 安装
#!date = 2024-11-03 22:30
#!author = ChatGPT

set -e -o pipefail

red="\033[31m"  ## 红色
green="\033[32m"  ## 绿色 
yellow="\033[33m"  ## 黄色
blue="\033[34m"  ## 蓝色
cyan="\033[36m"  ## 青色
reset="\033[0m"  ## 重置

sh_ver="1.0.1"

use_cdn=false

if ! curl -s --head --max-time 3 "https://www.google.com" > /dev/null; then
    use_cdn=true
fi

get_url() {
    local url=$1
    [ "$use_cdn" = true ] && echo "https://gh-proxy.com/$url" || echo "$url"
}

install_update() {
    apt update && apt upgrade -y
    apt install -y curl git gzip wget nano iptables tzdata
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" | tee /etc/timezone > /dev/null
}

check_ip_forward() {
    local sysctl_file="/etc/sysctl.conf"
    if ! sysctl net.ipv4.ip_forward | grep -q "1"; then
        sysctl -w net.ipv4.ip_forward=1
        echo "net.ipv4.ip_forward=1" | tee -a "$sysctl_file" > /dev/null
    fi
    if ! sysctl net.ipv6.conf.all.forwarding | grep -q "1"; then
        sysctl -w net.ipv6.conf.all.forwarding=1
        echo "net.ipv6.conf.all.forwarding=1" | tee -a "$sysctl_file" > /dev/null
    fi
    sysctl -p > /dev/null
}

get_schema() {
    arch_raw=$(uname -m)
    case "${arch_raw}" in
        'x86_64') arch='amd64';;
        'x86' | 'i686' | 'i386') arch='386';;
        'aarch64' | 'arm64') arch='arm64';;
        'armv7l') arch='armv7';;
        's390x') arch='s390x';;
        *) echo -e "${red}不支持的架构：${arch_raw}${reset}"; exit 1;;
    esac
}

download_version() {
    local version_url=$(get_url "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt")
    version=$(curl -sSL "$version_url") || { echo -e "${red}获取 mihomo 远程版本失败${reset}"; exit 1; }
}

download_mihomo() {
    local version_file="/root/mihomo/version.txt"
    local filename
    download_version
    [[ "$arch" == 'amd64' ]] && filename="mihomo-linux-${arch}-compatible-${version}.gz" ||
    filename="mihomo-linux-${arch}-${version}.gz"
    local download_url=$(get_url "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${filename}")
    wget -t 3 -T 30 "${download_url}" -O "${filename}" || { echo -e "${red}mihomo 下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    gunzip "$filename" || { echo -e "${red}mihomo 解压失败${reset}"; exit 1; }
    mv "mihomo-linux-${arch}-compatible-${version}" mihomo 2>/dev/null || mv "mihomo-linux-${arch}-${version}" mihomo || { echo -e "${red}找不到解压后的文件${reset}"; exit 1; }
    chmod +x mihomo
    echo "$version" > "$version_file"
}

download_wbeui() {
    local wbe_file="/root/mihomo/ui"
    local wbe_url=$(get_url "https://github.com/metacubex/metacubexd.git")
    git clone "$wbe_url" -b gh-pages "$wbe_file" || { echo -e "${red}管理面板下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
}

download_service() {
    local system_file="/etc/systemd/system/mihomo.service"
    local service_url=$(get_url "https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Service/mihomo.service")
    curl -s -o "$system_file" "$service_url" || { echo -e "${red}系统服务下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    chmod +x "$system_file"
    systemctl enable mihomo
}

download_shell() {
    local shell_file="/usr/bin/mihomo"
    local sh_url=$(get_url "https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Script/mihomo/mihomo.sh")
    [ -f "$shell_file" ] && rm -f "$shell_file"
    wget -q -O "$shell_file" --no-check-certificate "$sh_url" || { echo -e "${red}mihomo 管理脚本下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    chmod +x "$shell_file"
    [[ ":$PATH:" != *":/usr/bin:"* ]] && export PATH="$PATH:/usr/bin"
    hash -r
}

download_config() {
    local config_url="https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Script/mihomo/config.sh"
    config_url=$(get_url "$config_url")
    bash <(curl -Ls "$config_url")
}

install_mihomo() {
    local folders="/root/mihomo"
    [ -d "$folders" ] && rm -rf "$folders"
    mkdir -p "$folders" && cd "$folders" 
    get_schema
    echo -e "当前系统架构：[ ${green}${arch_raw}${reset} ]" 
    download_version
    echo -e "当前软件版本：[ ${green}${version}${reset} ]"
    download_mihomo
    download_service
    download_wbeui
    download_shell
    read -p "$(echo -e "${green}安装完成，是否下载配置文件\n${yellow}你也可以上传自己的配置文件到 $folders 目录下\n${red}配置文件名称必须是 config.yaml ${reset}，是否继续(y/n): ")" choice
    case "$choice" in
        [Yy]* ) download_config ;;
        [Nn]* ) echo -e "${green}跳过配置文件下载${reset}" ;;
        * ) echo -e "${red}无效选择，跳过配置文件下载${reset}" ;;
    esac
    rm -f /root/install.sh
}

install_update
check_ip_forward
install_mihomo
