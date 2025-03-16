#!/bin/bash

#!name = mihomo 一键安装脚本 Beta
#!desc = 安装 & 配置
#!date = 2025-01-15 14:30
#!author = ChatGPT

set -e -o pipefail

red="\033[31m"  ## 红色
green="\033[32m"  ## 绿色 
yellow="\033[33m"  ## 黄色
blue="\033[34m"  ## 蓝色
cyan="\033[36m"  ## 青色
reset="\033[0m"  ## 重置

sh_ver="1.0.0"

use_cdn=false

check_network() {
    if ! curl -s --head --max-time 3 "https://www.google.com" > /dev/null; then
        use_cdn=true
    fi
}

get_url() {
    local url=$1
    local final_url=""
    final_url=$([ "$use_cdn" = true ] && echo "https://gh-proxy.com/$url" || echo "$url")
    if ! curl --silent --head --fail --max-time 3 "$final_url" > /dev/null; then
        echo -e "${red}连接失败，可能是网络或者代理站点不可用，请检查网络并稍后重试${reset}" >&2
        exit 1
    fi
    echo "$final_url"
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

update_system() {
    apt update && apt upgrade -y
    apt install -y curl git gzip wget nano iptables tzdata jq
}

check_ip_forward() {
    local sysctl_file="/etc/sysctl.conf"
    sysctl net.ipv4.ip_forward | grep -q "1" || {
        sysctl -w net.ipv4.ip_forward=1
        echo "net.ipv4.ip_forward=1" | tee -a "$sysctl_file" > /dev/null
    }
    sysctl net.ipv6.conf.all.forwarding | grep -q "1" || {
        sysctl -w net.ipv6.conf.all.forwarding=1
        echo "net.ipv6.conf.all.forwarding=1" | tee -a "$sysctl_file" > /dev/null
    }
    sysctl -p > /dev/null
}

download_alpha_version() {
    local version_url=$(get_url "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt")
    version=$(curl -sSL "$version_url") || { echo -e "${red}获取 mihomo 远程版本失败${reset}"; exit 1; }
}

download_latest_version() {
    local version_url="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"
    version=$(curl -sSL "$version_url" | jq -r '.tag_name' | sed 's/v//') || { echo -e "${red}获取 mihomo 远程版本失败${reset}"; exit 1;}
}

download_alpha_mihomo() {
    local version_file="/root/mihomo/version.txt"
    local filename
    get_schema
    download_alpha_version || { echo -e "${red}获取最新版本失败，请检查网络或源地址！${reset}"; exit 1; }
    [[ "$arch" == 'amd64' ]] && filename="mihomo-linux-${arch}-compatible-${version}.gz" ||
    filename="mihomo-linux-${arch}-${version}.gz"
    local download_url=$(get_url "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${filename}")
    wget -t 3 -T 30 "${download_url}" -O "${filename}" || { echo -e "${red}mihomo 下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    gunzip "$filename" || { echo -e "${red}mihomo 解压失败${reset}"; exit 1; }
    mv "mihomo-linux-${arch}-compatible-${version}" mihomo 2>/dev/null || mv "mihomo-linux-${arch}-${version}" mihomo || { echo -e "${red}找不到解压后的文件${reset}"; exit 1; }
    chmod +x mihomo
    echo "$version" > "$version_file"
}

download_latest_mihomo() {
    local version_file="/root/mihomo/version.txt"
    local filename
    get_schema
    download_latest_version || { echo -e "${red}获取最新版本失败，请检查网络或源地址！${reset}"; exit 1; }
    [[ "$arch" == 'amd64' ]] && filename="mihomo-linux-${arch}-compatible-v${version}.gz" ||
    filename="mihomo-linux-${arch}-v${version}.gz"
    local download_url=$(get_url "https://github.com/MetaCubeX/mihomo/releases/download/v${version}/${filename}")
    wget -t 3 -T 30 "${download_url}" -O "${filename}" || { echo -e "${red}mihomo 下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    gunzip "$filename" || { echo -e "${red}mihomo 解压失败${reset}"; exit 1; }
    mv "mihomo-linux-${arch}-compatible-v${version}" mihomo 2>/dev/null || mv "mihomo-linux-${arch}-v${version}" mihomo || { echo -e "${red}找不到解压后的文件${reset}"; exit 1; }
    chmod +x mihomo
    echo "$version" > "$version_file"
}

download_service() {
    local system_file="/etc/systemd/system/mihomo.service"
    local service_url=$(get_url "https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Service/mihomo.service")
    curl -s -o "$system_file" "$service_url" || { echo -e "${red}系统服务下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    chmod +x "$system_file"
    systemctl enable mihomo
}

download_wbeui() {
    local wbe_file="/root/mihomo/ui"
    local wbe_url="https://github.com/metacubex/metacubexd.git"
    git clone "$wbe_url" -b gh-pages "$wbe_file" || { echo -e "${red}管理面板下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
}

download_shell() {
    local shell_file="/usr/bin/mihomo"
    local sh_url=$(get_url "https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Script/Beta/mihomo/mihomo.sh")
    [ -f "$shell_file" ] && rm -f "$shell_file"
    wget -q -O "$shell_file" --no-check-certificate "$sh_url" || { echo -e "${red}mihomo 管理脚本下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    chmod +x "$shell_file"
    hash -r
}

install_mihomo() {
    local folders="/root/mihomo"
    local choice
    echo -e "${yellow}请选择版本：${reset}"
    echo -e "${green}1. 测试版 (Prerelease-Alpha)${reset}"
    echo -e "${green}2. 正式版 (Latest)${reset}"
    read -rp "请输入选项 (1/2): " choice
    [ -d "$folders" ] && rm -rf "$folders"
    mkdir -p "$folders" && cd "$folders"
    get_schema
    echo -e "${yellow}当前系统架构${reset}：【 ${green}${arch_raw}${reset} 】"
    case "$choice" in
        1)
            echo -e "${yellow}选择安装测试版${reset}"
            download_alpha_version || { echo -e "${red}获取测试版版本失败，请检查网络或源地址！${reset}"; exit 1; }
            echo -e "${yellow}当前软件版本${reset}：【 ${green}${version}${reset} 】"
            download_alpha_mihomo || { echo -e "${red}测试版安装失败${reset}"; exit 1; }
            ;;
        2)
            echo -e "${yellow}选择安装正式版${reset}"
            download_latest_version || { echo -e "${red}获取正式版版本失败，请检查网络或源地址！${reset}"; exit 1; }
            echo -e "${yellow}当前软件版本${reset}：【 ${green}v${version}${reset} 】"
            download_latest_mihomo || { echo -e "${red}正式版安装失败${reset}"; exit 1; }
            ;;
        *)
            echo -e "${red}无效选项，请输入 1 或 2${reset}"
            exit 1
            ;;
    esac
    download_service
    download_wbeui
    download_shell
    read -p "$(echo -e "${green}安装完成，是否下载配置文件\n${yellow}你也可以上传自己的配置文件到 $folders 目录下\n${red}配置文件名称必须是 config.yaml ${green}是否继续${reset}(y/n): ")" confirm
    case "$confirm" in
        [Yy]* ) config_mihomo ;;
        [Nn]* ) echo -e "${green}跳过配置文件下载${reset}" ;;
        * ) echo -e "${red}无效选择，跳过配置文件下载${reset}" ;;
    esac
    rm -f /root/install.sh
}

config_mihomo() {
    local folders="/root/mihomo"
    local config_file="${folders}/config.yaml"
    local iface=$(ip route | awk '/default/ {print $5}')
    ipv4=$(ip addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)
    ipv6=$(ip addr show "$iface" | awk '/inet6 / {print $2}' | cut -d/ -f1)
    echo -e "${cyan}-------------------------${reset}"
    echo -e "${yellow}1. TUN 模式${reset}"
    echo -e "${yellow}2. TProxy 模式${reset}"
    echo -e "${cyan}-------------------------${reset}"
    read -p "$(echo -e "请选择运行模式（${green}推荐使用 TUN 模式${reset}）请输入选择(1/2): ")" confirm
    confirm=${confirm:-1}
    case "$confirm" in
        1) config_url="https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Config/mihomo.yaml" ;;
        2) config_url="https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Config/mihomotp.yaml" ;;
        *) echo -e "${red}无效选择，跳过配置文件下载。${reset}"; return ;;
    esac
    config_url=$(get_url "$config_url")
    wget -q -O "${config_file}" "$config_url" || { echo -e "${red}配置文件下载失败${reset}"; exit 1; }
    while true; do
        read -p "请输入需要配置的机场数量（默认 1 个，最多 5 个）：" airport_count
        airport_count=${airport_count:-1}
        if [[ "$airport_count" =~ ^[1-5]$ ]]; then
            break
        else
            echo -e "${red}无效的数量，请输入 1 到 5 之间的正整数${reset}"
        fi
    done
    proxy_providers="proxy-providers:"
    for ((i=1; i<=airport_count; i++)); do
        read -p "请输入第 $i 个机场的订阅连接：" airport_url
        read -p "请输入第 $i 个机场的名称：" airport_name
        proxy_providers="$proxy_providers
  provider_0$i:
    url: \"$airport_url\"
    type: http
    interval: 86400
    health-check: {enable: true, url: \"https://www.youtube.com/generate_204\", interval: 300}
    override:
      additional-prefix: \"[$airport_name]\""
    done
    awk -v providers="$proxy_providers" '
    /^# 机场配置/ {
        print
        print providers
        next
    }
    { print }
    ' "$config_file" > temp.yaml && mv temp.yaml "$config_file"
    systemctl daemon-reload
    systemctl start mihomo
    echo -e "${green}恭喜你，你的 mihomo 已经配置完成并保存到 ${yellow}${config_file}${reset}"
    echo -e "${red}下面是 mihomo 管理面板地址和进入管理菜单命令${reset}"
    echo -e "${cyan}=========================${reset}"
    echo -e "${green}http://$ipv4:9090/ui ${reset}"
    echo -e "${green}mihomo          进入菜单 ${reset}"
    echo -e "${cyan}=========================${reset}"
}

check_network
update_system
check_ip_forward
install_mihomo
