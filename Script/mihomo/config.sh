#!/bin/bash

#!name = mihomo 配置文件脚本
#!desc = 配置文件
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

get_local_ip() {
    local iface=$(ip route | awk '/default/ {print $5}')
    ipv4=$(ip addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)
    ipv6=$(ip addr show "$iface" | awk '/inet6 / {print $2}' | cut -d/ -f1)
}

download_config() {
    local folders="/root/mihomo"
    local config_file="${folders}/config.yaml"
    echo -e "${cyan}-------------------------${reset}"
    echo -e "${yellow}1. TUN 模式${reset}"
    echo -e "${yellow}2. TProxy 模式${reset}"
    echo -e "${cyan}-------------------------${reset}"
    read -p "$(echo -e "请选择运行模式（${green}推荐使用 TUN 模式${reset}）请输入选择(1/2): ")" choice
    choice=${choice:-1}
    case "$choice" in
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
    health-check: {enable: true, url: \"https://www.gstatic.com/generate_204\", interval: 300}
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
    get_local_ip
    echo -e "${green}恭喜你，你的 mihomo 已经配置完成并保存到 ${yellow}${config_file}${reset}"
    echo -e "下面是 mihomo 管理面板地址和进入管理菜单命令"
    echo -e "${cyan}=========================${reset}"
    echo -e "${green}http://$ipv4:9090/ui ${reset}"
    echo -e "${green}mihomo          进入菜单 ${reset}"
    echo -e "${cyan}=========================${reset}"
}

download_config
