#!/bin/bash

#!name = v2ray 一键管理脚本
#!desc = 管理 & 面板
#!date = 2025-01-05 11:30
#!author = ChatGPT

set -e -o pipefail

red="\033[31m"  ## 红色
green="\033[32m"  ## 绿色 
yellow="\033[33m"  ## 黄色
blue="\033[34m"  ## 蓝色
cyan="\033[36m"  ## 青色
reset="\033[0m"  ## 重置

sh_ver="0.0.5"

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

check_installation() {
    local file="/root/v2ray/v2ray"
    if [ ! -f "$file" ]; then
        echo -e "${red}请先安装 v2ray${reset}"
        start_menu
        return 1
    fi
    return 0
}

start_menu() {
    echo && echo -n -e "${yellow}* 按回车返回主菜单 *${reset}" && read temp
    menu
}

show_status() {
    local file="/root/v2ray/v2ray"
    local version_file="/root/v2ray/version.txt"
    local install_status run_status auto_start software_version
    if [ ! -f "$file" ]; then
        install_status="${red}未安装${reset}"
        run_status="${red}未运行${reset}"
        auto_start="${red}未设置${reset}"
        software_version="${red}未安装${reset}"
    else
        install_status="${green}已安装${reset}"
        if pgrep -f "$file" > /dev/null; then
            run_status="${green}已运行${reset}"
        else
            run_status="${red}未运行${reset}"
        fi
        if systemctl is-enabled v2ray.service &>/dev/null; then
            auto_start="${green}已设置${reset}"
        else
            auto_start="${red}未设置${reset}"
        fi
        if [ -f "$version_file" ]; then
            software_version=$(cat "$version_file")
        else
            software_version="${red}未安装${reset}"
        fi
    fi
    echo -e "安装状态：${install_status}"
    echo -e "运行状态：${run_status}"
    echo -e "开机自启：${auto_start}"
    echo -e "脚本版本：${green}${sh_ver}${reset}"
    echo -e "软件版本：${green}${software_version}${reset}"
}

service_v2ray() {
    check_installation || { start_menu; return; }
    local action="$1"
    action_text=""
    case "$action" in
        start) action_text="启动" ;;
        stop) action_text="停止" ;;
        restart) action_text="重启" ;;
        enable) action_text="设置开机自启" ;;
        disable) action_text="取消开机自启" ;;
    esac
    if [[ "$action" == "enable" || "$action" == "disable" ]]; then
        local is_enabled=$(systemctl is-enabled --quiet v2ray && echo "enabled" || echo "disabled")
        if [[ "$action" == "enable" && "$is_enabled" == "enabled" ]] || 
           [[ "$action" == "disable" && "$is_enabled" == "disabled" ]]; then
            echo -e "${yellow}已${action_text}，无需重复操作${reset}"
        else
            echo -e "${green}正在 ${action_text} v2ray...${reset}"
            if systemctl "$action" v2ray; then
                echo -e "${green}${action_text}成功${reset}"
            else
                echo -e "${red}${action_text}失败${reset}"
            fi
        fi
        start_menu
        return
    fi
    local service_status=$(systemctl is-active --quiet v2ray && echo "active" || echo "inactive")
    if [[ "$action" == "start" && "$service_status" == "active" ]] || 
       [[ "$action" == "stop" && "$service_status" == "inactive" ]]; then
        echo -e "${yellow}已${action_text}，无需重复操作${reset}"
        start_menu
        return
    fi
    echo -e "${green}正在 ${action_text} v2ray...${reset}"
    if systemctl "$action" v2ray; then
        echo -e "${green}${action_text}成功${reset}"
    else
        echo -e "${red}${action_text}失败${reset}"
    fi
    start_menu
}

start_v2ray() { service_v2ray start; }
stop_v2ray() { service_v2ray stop; }
restart_v2ray() { service_v2ray restart; }
enable_v2ray() { service_v2ray enable; }
disable_v2ray() { service_v2ray disable; }

uninstall_v2ray() {
    check_installation || { start_menu; return; }
    local folders="/root/v2ray"
    local shell_file="/usr/bin/v2ray"
    local system_file="/etc/systemd/system/v2ray.service"
    read -p "$(echo -e "${red}警告：卸载后将删除当前配置和文件！\n${yellow}确认卸载 v2ray 吗？${reset} (y/n): ")" input
    case "$input" in
        [Yy]* ) echo -e "${green}v2ray 卸载中请等待${reset}";;
        [Nn]* ) echo -e "${yellow}v2ray 卸载已取消${reset}"; start_menu; return;;
        * ) echo -e "${red}无效选择，卸载已取消${reset}"; start_menu; return;;
    esac
    sleep 2s
    echo -e "${green}v2ray 卸载命令已发出${reset}"
    systemctl stop v2ray.service 2>/dev/null || { echo -e "${red}停止 v2ray 服务失败${reset}"; exit 1; }
    systemctl disable v2ray.service 2>/dev/null || { echo -e "${red}禁用 v2ray 服务失败${reset}"; exit 1; }
    rm -f "$system_file" || { echo -e "${red}删除服务文件失败${reset}"; exit 1; }
    rm -rf "$folders" || { echo -e "${red}删除相关文件夹失败${reset}"; exit 1; }
    systemctl daemon-reload || { echo -e "${red}重新加载 systemd 配置失败${reset}"; exit 1; }
    sleep 3s
    if [ ! -f "$system_file" ] && [ ! -d "$folders" ]; then
        echo -e "${green}v2ray 卸载完成${reset}"
        echo ""
        echo -e "卸载成功，如果你想删除此脚本，则退出脚本后，输入 ${green}rm $shell_file -f${reset} 进行删除"
        echo ""
    else
        echo -e "${red}卸载过程中出现问题，请手动检查${reset}"
    fi
    start_menu
}

install_v2ray() {
    check_network
    local folders="/root/v2ray"
    local install_url="https://raw.githubusercontent.com/Abcd789JK/Tools/main/Script/Beta/v2ray/install.sh"
    if [ -d "$folders" ]; then
        echo -e "${red}检测到 v2ray 已经安装在 ${folders} 目录下${reset}"
        read -p "$(echo -e "${red}警告：重新安装将删除当前配置和文件！\n${yellow}是否删除并重新安装？${reset} (y/n): ")" input
        case "$input" in
            [Yy]* ) echo -e "${green}开始删除，重新安装中请等待${reset}";;
            [Nn]* ) echo -e "${yellow}取消安装，保持现有安装${reset}"; start_menu; return;;
            * ) echo -e "${red}无效选择，安装已取消${reset}"; start_menu; return;;
        esac
    fi
    bash <(curl -Ls "$(get_url "$install_url")")
}

download_version() {
    local version_url="https://api.github.com/repos/v2fly/v2ray-core/releases/latest"
    version=$(curl -sSL "$version_url" | jq -r '.tag_name' | sed 's/v//') || { echo -e "${red}获取 v2ray 远程版本失败${reset}"; exit 1;}
}

download_v2ray() {
    check_network
    local version_file="/root/v2ray/version.txt"
    local filename
    arch_raw=$(uname -m)
    arch_raw=$(uname -m)
    case "${arch_raw}" in
        'x86_64')    arch='64';;
        'x86' | 'i686' | 'i386')     arch='32';;
        'aarch64' | 'arm64') arch='arm64-v8a';;
        'armv7' | 'armv7l')   arch='arm32-v7a';;
        's390x')    arch='s390x';;
        *)          echo -e "${red}不支持的架构: ${arch_raw}${reset}"; exit 1;;
    esac
    download_version || { echo -e "${red}获取最新版本失败，请检查网络或源地址！${reset}"; start_menu; return; }
    filename="v2ray-linux-${arch}.zip" 
    local download_url=$(get_url "https://github.com/v2fly/v2ray-core/releases/download/v${version}/${filename}")
    wget -t 3 -T 30 "${download_url}" -O "${filename}" || { echo -e "${red}v2ray 下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    unzip "$filename" && rm "$filename" || { echo -e "${red}v2ray 解压失败${reset}"; exit 1; }
    chmod +x v2ray
    echo "$version" > "$version_file"
}

update_v2ray() {
    check_installation || { start_menu; return; }
    local folders="/root/v2ray"
    local version_file="/root/v2ray/version.txt"
    echo -e "${green}开始检查软件是否有更新${reset}"
    cd "$folders" || exit
    download_version || { echo -e "${red}获取最新版本失败，请检查网络或源地址！${reset}"; start_menu; return; }
    local current_version
    if [ -f "$version_file" ]; then
        current_version=$(cat "$version_file")
    else
        echo -e "${red}请先安装 v2ray${reset}"
        start_menu
        return
    fi
    local latest_version="$version"
    if [ "$current_version" == "$latest_version" ]; then
        echo -e "${green}当前已是最新，无需更新${reset}"
        start_menu
        return
    fi
    read -p "$(echo -e "${yellow}检查到有更新，是否升级到最新版本？${reset} (y/n): ")" input
    case "$input" in
        [Yy]*) echo -e "${green}开始升级，升级中请等待${reset}" ;;
        [Nn]*) echo -e "${yellow}取消升级，保持现有版本${reset}"; start_menu; return ;;
        *) echo -e "${red}无效选择，升级已取消${reset}"; start_menu; return ;;
    esac
    download_v2ray
    sleep 2s
    echo -e "${yellow}更新完成，当前版本已更新为：${reset}【 ${green}${latest_version}${reset} 】"
    systemctl restart v2ray
    start_menu
}

update_shell() {
    check_network
    local shell_file="/usr/bin/v2ray"
    local sh_ver_url="https://raw.githubusercontent.com/Abcd789JK/Tools/main/Script/Beta/v2ray/v2ray.sh"
    local sh_new_ver=$(wget --no-check-certificate -qO- "$(get_url "$sh_ver_url")" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    echo -e "${green}开始检查脚本是否有更新${reset}"
    if [ "$sh_ver" == "$sh_new_ver" ]; then
        echo -e "${green}当前已是最新，无需更新${reset}"
        start_menu
        return
    fi
    read -p "$(echo -e "${yellow}检查到有更新，是否升级到最新版本？${reset} (y/n): ")" input
    case "$input" in
        [Yy]* ) echo -e "${green}开始升级，升级中请等待${reset}";;
        [Nn]* ) echo -e "${yellow}取消升级，保持现有版本${reset}"; start_menu; return;;
        * ) echo -e "${red}无效选择，升级已取消${reset}"; start_menu; return;;
    esac
    [ -f "$shell_file" ] && rm "$shell_file"
    wget -O "$shell_file" --no-check-certificate "$(get_url "$sh_ver_url")"
    chmod +x "$shell_file"
    hash -r
    echo -e "${yellow}更新完成，当前版本已更新为：${reset}【 ${green}${sh_new_ver}${reset} 】"
    echo -e "${yellow}3 秒后执行新脚本${reset}"
    sleep 3s
    "$shell_file"
}


config_v2ray() {
    local config_file="/root/v2ray/config.json"
    local config_url=$(get_url "https://raw.githubusercontent.com/Abcd789JK/Tools/refs/heads/main/Config/v2ray.json")
    curl -s -o "$config_file" "$config_url"
    echo -e ""
    echo -e "${green}开始配置 v2ray ${reset}"
    echo -e ""
    read -rp "是否快速生成配置文件？(y/n 默认[y]): " confirm
    confirm=${confirm:-y}
    if [[ "$confirm" == [Yy] ]]; then
        echo -e "请选择协议："
        echo -e "${green}1${reset}、vmess+tcp"
        echo -e "${green}2${reset}、vmess+ws"
        echo -e "${green}3${reset}、vmess+tcp+tls"
        echo -e "${green}4${reset}、vmess+ws+tls"
        read -rp "输入数字选择协议 (1-4 默认[1]): " confirm
        confirm=${confirm:-1}
        PORT=$(shuf -i 10000-65000 -n 1)
        UUID=$(cat /proc/sys/kernel/random/uuid)
        if [[ "$confirm" == "2" || "$confirm" == "4" ]]; then
            WS_PATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)
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
    else
        echo -e "请选择协议："
        echo -e "${green}1${reset}、vmess+tcp"
        echo -e "${green}2${reset}、vmess+ws"
        echo -e "${green}3${reset}、vmess+tcp+tls"
        echo -e "${green}4${reset}、vmess+ws+tls"
        read -rp "输入数字选择协议 (1-4 默认[1]): " confirm
        confirm=${confirm:-1}
        read -p "请输入监听端口 (留空以随机生成端口): " PORT
        if [[ -z "$PORT" ]]; then
            PORT=$(shuf -i 10000-65000 -n 1)
        elif [[ "$PORT" -lt 10000 || "$PORT" -gt 65000 ]]; then
            echo -e "${red}端口号必须在10000到65000之间。${reset}"
            exit 1
        fi
        read -p "请输入 v2ray UUID (留空以生成随机UUID): " UUID
        if [[ -z "$UUID" ]]; then
            UUID=$(cat /proc/sys/kernel/random/uuid)
        fi
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
    echo -e "${green}读取配置文件${reset}"
    config=$(cat "$config_file")
    echo -e "${green}修改配置文件${reset}"
    case $confirm in
        1)  # vmess + tcp
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "tcp" |
                del(.inbounds[0].streamSettings.wsSettings) |
                del(.inbounds[0].streamSettings.tlsSettings)
            ')
            ;;
        2)  # vmess + ws
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" --arg ws_path "/$WS_PATH" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "ws" |
                .inbounds[0].streamSettings.wsSettings.path = $ws_path |
                del(.inbounds[0].streamSettings.tlsSettings) |
                del(.inbounds[0].streamSettings.wsSettings.headers)
            ')
            ;;
        3)  # vmess + tcp + tls
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "tcp" |
                .inbounds[0].streamSettings.security = "tls" |
                .inbounds[0].streamSettings.tlsSettings = {
                    "certificates": [
                        {
                            "certificateFile": "/root/ssl/server.crt",
                            "keyFile": "/root/ssl/server.key"
                        }
                    ]
                }
            ')
            ;;
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
                            "certificateFile": "/root/ssl/server.crt",
                            "keyFile": "/root/ssl/server.key"
                        }
                    ]
                } |
                del(.inbounds[0].streamSettings.wsSettings.headers)
            ')
            ;;
        *)
            echo -e "${red}无效选项${reset}"
            exit 1
            ;;
    esac
    echo -e "${green}写入配置文件${reset}"
    echo "$config" > "$config_file"
    echo -e "${green}验证修改后的配置文件格式${reset}"
    if ! jq . "$config_file" >/dev/null 2>&1; then
        echo -e "${red}修改后的配置文件格式无效，请检查文件${reset}"
        exit 1
    fi
    echo -e "${green}v2ray 配置已完成并保存到 ${config_file} 文件夹${reset}"
    echo -e "${green}v2ray 配置完成，正在启动中${reset}"
    systemctl daemon-reload
    systemctl start v2ray
    systemctl enable v2ray
    echo -e "${green}v2ray 已成功启动并设置为开机自启${reset}"
}

menu() {
    clear
    echo "================================="
    echo -e "${green}欢迎使用 v2ray 一键脚本 Beta 版${reset}"
    echo -e "${green}作者：${yellow}ChatGPT JK789${reset}"
    echo -e "${red}更换配置说明：${reset}"
    echo -e "${red} 1. 更换配置不会保存以前的配置"
    echo -e "${red} 2. 需要全部重新添加配置信息${reset}"
    echo "================================="
    echo -e "${green} 0${reset}. 更新脚本"
    echo -e "${green}10${reset}. 退出脚本"
    echo -e "${green}20${reset}. 更换配置"
    echo "---------------------------------"
    echo -e "${green} 1${reset}. 安装 v2ray"
    echo -e "${green} 2${reset}. 更新 v2ray"
    echo -e "${green} 3${reset}. 卸载 v2ray"
    echo "---------------------------------"
    echo -e "${green} 4${reset}. 启动 v2ray"
    echo -e "${green} 5${reset}. 停止 v2ray"
    echo -e "${green} 6${reset}. 重启 v2ray"
    echo "---------------------------------"
    echo -e "${green} 7${reset}. 添加开机自启"
    echo -e "${green} 8${reset}. 关闭开机自启"
    echo "================================="
    show_status
    echo "================================="
    read -p "请输入上面选项：" input
    case "$input" in
        1) install_v2ray ;;
        2) update_v2ray ;;
        3) uninstall_v2ray ;;
        4) start_v2ray ;;
        5) stop_v2ray ;;
        6) restart_v2ray ;;
        7) enable_v2ray ;;
        8) disable_v2ray ;;
        20) config_v2ray ;;
        10) exit 0 ;;
        0) update_shell ;;
        *) echo -e "${red}无效选项，请重新选择${reset}" 
           exit 1 ;;
    esac
}

menu
