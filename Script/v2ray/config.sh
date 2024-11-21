#!/bin/bash

#!name = v2ray 一键安装脚本
#!desc = 安装
#!date = 2024-11-16 22:30
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

Config() {
    local config_file="/root/v2ray/config"
    local config_url=$(get_url "https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Config/v2ray.json")
    curl -s -o "$config_file" "$config_url"
    echo -e ""
    echo -e "${green}开始配置 v2ray ${reset}"
    echo -e ""
    # 询问是否快速配置，默认值为 y
    read -rp "是否快速生成配置文件？(y/n 默认[y]): " confirm
    confirm=${confirm:-y}  # 如果用户未输入，默认值为 y
    if [[ "$confirm" == [Yy] ]]; then
        # 快速配置：选择协议
        echo -e "请选择协议："
        echo -e "${green}1${reset}、vmess+tcp"
        echo -e "${green}2${reset}、vmess+ws"
        echo -e "${green}3${reset}、vmess+tcp+tls"
        echo -e "${green}4${reset}、vmess+ws+tls"
        read -rp "输入数字选择协议 (1-4 默认[1]): " confirm
        confirm=${confirm:-1}  # 默认为 1
        # 随机生成配置项
        PORT=$(shuf -i 10000-65000 -n 1)
        UUID=$(cat /proc/sys/kernel/random/uuid)
        # 如果选择了 WebSocket 协议
        if [[ "$confirm" == "2" || "$confirm" == "4" ]]; then
            WS_PATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)
        fi
        # 显示生成的配置
        echo -e "配置文件已生成："
        case $confirm in
            1) echo -e "  - 协议: ${green}vmess+tcp${reset}" ;;
            2) echo -e "  - 协议: ${green}vmess+ws${reset}" ;;
            3) echo -e "  - 协议: ${green}vmess+tcp+tls${reset}" ;;
            4) echo -e "  - 协议: ${green}vmess+ws+tls${reset}" ;;
            *) echo -e "${red}无效选项${reset}" && exit 1 ;;
        esac
        echo -e "  - 端口: ${green}$PORT${reset}"
        echo -e "  - UUID: ${green}$UUID${reset}"
        if [[ "$confirm" == "2" || "$confirm" == "4" ]]; then
            echo -e "  - WS路径: ${green}/$WS_PATH${reset}"
        fi
    else
        # 手动配置
        echo -e "请选择协议："
        echo -e "${green}1${reset}、vmess+tcp"
        echo -e "${green}2${reset}、vmess+ws"
        echo -e "${green}3${reset}、vmess+tcp+tls"
        echo -e "${green}4${reset}、vmess+ws+tls"
        read -rp "输入数字选择协议 (1-4 默认[1]): " confirm
        confirm=${confirm:-1}  # 默认为 1
        # 端口处理
        read -p "请输入监听端口 (留空以随机生成端口): " PORT
        if [[ -z "$PORT" ]]; then
            PORT=$(shuf -i 10000-65000 -n 1)
        elif [[ "$PORT" -lt 10000 || "$PORT" -gt 65000 ]]; then
            echo -e "${red}端口号必须在10000到65000之间。${reset}"
            exit 1
        fi
        # UUID 处理
        read -p "请输入 v2ray UUID (留空以生成随机UUID): " UUID
        if [[ -z "$UUID" ]]; then
            UUID=$(cat /proc/sys/kernel/random/uuid)
        fi
        # WebSocket 路径处理 (仅限选择2或4时)
        if [[ "$confirm" == "2" || "$confirm" == "4" ]]; then
            read -p "请输入 WebSocket 路径 (留空以生成随机路径): " WS_PATH
            if [[ -z "$WS_PATH" ]]; then
                WS_PATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)
            else
                WS_PATH="${WS_PATH#/}"
            fi
        fi
        echo -e "配置文件已生成："
        case $confirm in
            1) echo -e "  - 协议: ${green}vmess+tcp${reset}" ;;
            2) echo -e "  - 协议: ${green}vmess+ws${reset}" ;;
            3) echo -e "  - 协议: ${green}vmess+tcp+tls${reset}" ;;
            4) echo -e "  - 协议: ${green}vmess+ws+tls${reset}" ;;
            *) echo -e "${red}无效选项${reset}" && exit 1 ;;
        esac
        echo -e "  - 端口: ${green}$PORT${reset}"
        echo -e "  - UUID: ${green}$UUID${reset}"
        if [[ "$confirm" == "2" || "$confirm" == "4" ]]; then
            echo -e "  - WS路径: ${green}/$WS_PATH${reset}"
        fi
    fi

    # 读取配置文件
    echo -e "${green}读取配置文件${reset}"
    config=$(cat "$config_file")
    # 修改配置文件
    echo -e "${green}修改配置文件${reset}"
    case $confirm in
        1)  # vmess + tcp
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "tcp" |
                del(.inbounds[0].streamSettings.wsSettings) |
                del(.inbounds[0].streamSettings.tlsSettings)
            ') ;;
        2)  # vmess + ws
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" --arg ws_path "/$WS_PATH" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "ws" |
                .inbounds[0].streamSettings.wsSettings.path = $ws_path |
                del(.inbounds[0].streamSettings.tlsSettings)
            ') ;;
        3)  # vmess + tcp + tls
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "tcp" |
                .inbounds[0].streamSettings.security = "tls" |
                .inbounds[0].streamSettings.tlsSettings = {
                    "certificates": [
                        {
                            "certificateFile": "/root/v2ray/ssl/server.crt",
                            "keyFile": "/root/v2ray/ssl/server.key"
                        }
                    ]
                }
            ') ;;
        4)  # vmess + ws + tls
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" --arg ws_path "/$WS_PATH" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "ws" |
                .inbounds[0].streamSettings.wsSettings.path = $ws_path |
                .inbounds[0].streamSettings.security = "tls" |
                .inbounds[0].streamSettings.tlsSettings = {
                    "certificates": [
                        {
                            "certificateFile": "/root/v2ray/ssl/server.crt",
                            "keyFile": "/root/v2ray/ssl/server.key"
                        }
                    ]
                }
            ') ;;
        *)
            echo -e "${red}无效选项${reset}"
            exit 1 ;;
    esac

    # 写入配置文件
    echo -e "${green}写入配置文件${reset}"
    echo "$config" > "$config_file"
    
    # 验证修改后的配置文件
    echo -e "${green}验证修改后的配置文件格式${reset}"
    if ! jq . "$config_file" >/dev/null 2>&1; then
        echo -e "${red}修改后的配置文件格式无效，请检查文件${reset}"
        exit 1
    fi
    echo -e "${green}v2ray 配置已完成并保存到 ${config_file}${reset}"
    # 启动服务
    systemctl daemon-reload
    systemctl start v2ray
    systemctl enable v2ray
    echo -e "${green}v2ray 已成功启动并设置为开机自启${reset}"
}

Config