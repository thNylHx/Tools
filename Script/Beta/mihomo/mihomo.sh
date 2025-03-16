#!/bin/bash

#!name = mihomo 一键管理脚本 Beta
#!desc = 管理 & 面板
#!date = 2025-01-15 14:30
#!author = ChatGPT

set -e -o pipefail

red="\033[31m"  # 红色
green="\033[32m"  # 绿色
yellow="\033[33m"  # 黄色
blue="\033[34m"  # 蓝色
cyan="\033[36m"  # 青色
reset="\033[0m"  # 重置

sh_ver="1.0.6"

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
    local file="/root/mihomo/mihomo"
    if [ ! -f "$file" ]; then
        echo -e "${red}请先安装 mihomo${reset}"
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
    local file="/root/mihomo/mihomo"
    local version_file="/root/mihomo/version.txt"
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
        if systemctl is-enabled mihomo.service &>/dev/null; then
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

service_mihomo() {
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
        local is_enabled=$(systemctl is-enabled --quiet mihomo && echo "enabled" || echo "disabled")
        if [[ "$action" == "enable" && "$is_enabled" == "enabled" ]] || 
           [[ "$action" == "disable" && "$is_enabled" == "disabled" ]]; then
            echo -e "${yellow}已${action_text}，无需重复操作${reset}"
        else
            echo -e "${green}正在 ${action_text} mihomo...${reset}"
            if systemctl "$action" mihomo; then
                echo -e "${green}${action_text}成功${reset}"
            else
                echo -e "${red}${action_text}失败${reset}"
            fi
        fi
        start_menu
        return
    fi
    local service_status=$(systemctl is-active --quiet mihomo && echo "active" || echo "inactive")
    if [[ "$action" == "start" && "$service_status" == "active" ]] || 
       [[ "$action" == "stop" && "$service_status" == "inactive" ]]; then
        echo -e "${yellow}已${action_text}，无需重复操作${reset}"
        start_menu
        return
    fi
    echo -e "${green}正在 ${action_text} mihomo...${reset}"
    if systemctl "$action" mihomo; then
        echo -e "${green}${action_text}成功${reset}"
    else
        echo -e "${red}${action_text}失败${reset}"
    fi
    start_menu
}

start_mihomo() { service_mihomo start; }
stop_mihomo() { service_mihomo stop; }
restart_mihomo() { service_mihomo restart; }
enable_mihomo() { service_mihomo enable; }
disable_mihomo() { service_mihomo disable; }

uninstall_mihomo() {
    check_installation || { start_menu; return; }
    local folders="/root/mihomo"
    local shell_file="/usr/bin/mihomo"
    local system_file="/etc/systemd/system/mihomo.service"
    read -p "$(echo -e "${red}警告：卸载后将删除当前配置和文件！\n${yellow}确认卸载 mihomo 吗？${reset} (y/n): ")" input
    case "$input" in
        [Yy]* ) echo -e "${green}mihomo 卸载中请等待${reset}";;
        [Nn]* ) echo -e "${yellow}mihomo 卸载已取消${reset}"; start_menu; return;;
        * ) echo -e "${red}无效选择，卸载已取消${reset}"; start_menu; return;;
    esac
    sleep 2s
    echo -e "${green}mihomo 卸载命令已发出${reset}"
    systemctl stop mihomo.service 2>/dev/null || { echo -e "${red}停止 mihomo 服务失败${reset}"; exit 1; }
    systemctl disable mihomo.service 2>/dev/null || { echo -e "${red}禁用 mihomo 服务失败${reset}"; exit 1; }
    rm -f "$system_file" || { echo -e "${red}删除服务文件失败${reset}"; exit 1; }
    rm -rf "$folders" || { echo -e "${red}删除相关文件夹失败${reset}"; exit 1; }
    systemctl daemon-reload || { echo -e "${red}重新加载 systemd 配置失败${reset}"; exit 1; }
    sleep 3s
    if [ ! -f "$system_file" ] && [ ! -d "$folders" ]; then
        echo -e "${green}mihomo 卸载完成${reset}"
        echo ""
        echo -e "卸载成功，如果你想删除此脚本，则退出脚本后，输入 ${green}rm $shell_file -f${reset} 进行删除"
        echo ""
    else
        echo -e "${red}卸载过程中出现问题，请手动检查${reset}"
    fi
    start_menu
}

install_mihomo() {
    check_network
    local folders="/root/mihomo"
    local install_url="https://raw.githubusercontent.com/Abcd789JK/Tools/main/Script/Beta/mihomo/install.sh"
    if [ -d "$folders" ]; then
        echo -e "${red}检测到 mihomo 已经安装在 ${folders} 目录下${reset}"
        read -p "$(echo -e "${red}警告：重新安装将删除当前配置和文件！\n${yellow}是否删除并重新安装？${reset} (y/n): ")" input
        case "$input" in
            [Yy]* ) echo -e "${green}开始删除，重新安装中请等待${reset}";;
            [Nn]* ) echo -e "${yellow}取消安装，保持现有安装${reset}"; start_menu; return;;
            * ) echo -e "${red}无效选择，安装已取消${reset}"; start_menu; return;;
        esac
    fi
    bash <(curl -Ls "$(get_url "$install_url")")
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

download_alpha_version() {
    check_network
    local version_url=$(get_url "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt")
    version=$(curl -sSL "$version_url") || { echo -e "${red}获取 mihomo 远程版本失败${reset}"; exit 1; }
}

download_latest_version() {
    check_network
    local version_url="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"
    version=$(curl -sSL "$version_url" | jq -r '.tag_name' | sed 's/v//') || { echo -e "${red}获取 mihomo 远程版本失败${reset}"; exit 1;}
}

download_alpha_mihomo() {
    check_network
    local version_file="/root/mihomo/version.txt"
    local filename
    get_schema
    download_alpha_version || { echo -e "${red}获取最新版本失败，请检查网络或源地址！${reset}"; start_menu; return; }
    [[ "$arch" == 'amd64' ]] && filename="mihomo-linux-${arch}-compatible-${version}.gz" ||
    filename="mihomo-linux-${arch}-${version}.gz"
    local download_url=$(get_url "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${filename}")
    wget -t 3 -T 30 "${download_url}" -O "${filename}" || { echo -e "${red}mihomo 下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    gunzip "$filename" || { echo -e "${red}mihomo 解压失败${reset}"; exit 1; }
    mv -f "mihomo-linux-${arch}-compatible-${version}" mihomo 2>/dev/null || mv -f "mihomo-linux-${arch}-${version}" mihomo || { echo -e "${red}找不到解压后的文件${reset}"; exit 1; }
    chmod +x mihomo
    echo "$version" > "$version_file"
}

download_latest_mihomo() {
    check_network
    local version_file="/root/mihomo/version.txt"
    local filename
    get_schema
    download_latest_version || { echo -e "${red}获取最新版本失败，请检查网络或源地址！${reset}"; start_menu; return; }
    [[ "$arch" == 'amd64' ]] && filename="mihomo-linux-${arch}-compatible-v${version}.gz" ||
    filename="mihomo-linux-${arch}-v${version}.gz"
    local download_url=$(get_url "https://github.com/MetaCubeX/mihomo/releases/download/v${version}/${filename}")
    wget -t 3 -T 30 "${download_url}" -O "${filename}" || { echo -e "${red}mihomo 下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    gunzip "$filename" || { echo -e "${red}mihomo 解压失败${reset}"; exit 1; }
    mv -f "mihomo-linux-${arch}-compatible-v${version}" mihomo 2>/dev/null || mv -f "mihomo-linux-${arch}-v${version}" mihomo || { echo -e "${red}找不到解压后的文件${reset}"; exit 1; }
    chmod +x mihomo
    echo "$version" > "$version_file"
}

update_mihomo() {
    check_installation || { start_menu; return; }
    local folders="/root/mihomo"
    local version_file="/root/mihomo/version.txt"
    echo -e "${green}开始检查软件是否有更新${reset}"
    cd "$folders" || exit
    local current_version
    if [ -f "$version_file" ]; then
        current_version=$(cat "$version_file")
    else
        echo -e "${red}请先安装 mihomo${reset}"
        start_menu
        return
    fi
    if [[ "$current_version" == *alpha* ]]; then
        download_version_type="alpha"
    else
        download_version_type="latest"
    fi
    if [ "$download_version_type" == "alpha" ]; then
        download_alpha_version || { echo -e "${red}获取最新版本失败，请检查网络或源地址！${reset}"; start_menu; return; }
    else
        download_latest_version || { echo -e "${red}获取最新版本失败，请检查网络或源地址！${reset}"; start_menu; return; }
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
    if [ "$download_version_type" == "alpha" ]; then
        download_alpha_mihomo || { echo -e "${red}mihomo 下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    else
        download_latest_mihomo || { echo -e "${red}mihomo 下载失败，可能是网络问题，建议重新运行本脚本重试下载${reset}"; exit 1; }
    fi
    sleep 2s
    echo -e "${yellow}更新完成，当前版本已更新为：${reset}【 ${green}${latest_version}${reset} 】"
    systemctl restart mihomo
    start_menu
}

update_shell() {
    check_network
    local shell_file="/usr/bin/mihomo"
    local sh_ver_url="https://raw.githubusercontent.com/Abcd789JK/Tools/main/Script/Beta/mihomo/mihomo.sh"
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

config_mihomo() {
    check_installation || { start_menu; return; }
    check_network
    local folders="/root/mihomo"
    local config_file="/root/mihomo/config.yaml"
    local iface=$(ip route | awk '/default/ {print $5}')
    ipv4=$(ip addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)
    ipv6=$(ip addr show "$iface" | awk '/inet6 / {print $2}' | cut -d/ -f1)
    echo -e "${cyan}-------------------------${reset}"
    echo -e "${yellow}1. TUN 模式${reset}"
    echo -e "${yellow}2. TProxy 模式${reset}"
    echo -e "${cyan}-------------------------${reset}"
    read -p "$(echo -e "请选择运行模式（${green}推荐使用 TUN 模式${reset}）请输入选择(1/2): ")" input
    input=${input:-1}
    case "$input" in
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
    echo -e ""
    echo -e "${yellow}mihomo          进入菜单 ${reset}"
    echo -e "${cyan}=========================${reset}"
    start_menu
}

switch_version() {
    check_installation || { start_menu; return; }
    local folders="/root/mihomo"
    local version_file="/root/mihomo/version.txt"
    cd "$folders" || exit
    local current_version
    local download_version_type

    if [ -f "$version_file" ]; then
        current_version=$(cat "$version_file")
        if [[ "$current_version" == *alpha* ]]; then
            download_version_type="alpha"
        else
            download_version_type="latest"
        fi
    else
        echo -e "${red}请先安装 mihomo${reset}"
        start_menu
        return
    fi
    echo -e "${yellow}请选择版本：${reset}"
    echo -e "${green}1. 测试版 (Prerelease-Alpha)${reset}"
    echo -e "${green}2. 正式版 (Latest)${reset}"
    read -rp "请输入选项 (1/2): " choice
    case "$choice" in
        1)
            if [[ "$download_version_type" == "alpha" ]]; then
                echo -e "${yellow}当前已经是测试版，无需重复操作${reset}"
                start_menu
                return
            fi
            echo -e "${yellow}准备切换到测试版${reset}"
            download_alpha_version || { echo -e "${red}获取测试版版本失败，请检查网络或源地址！${reset}"; exit 1; }
            download_alpha_mihomo || { echo -e "${red}测试版安装失败${reset}"; exit 1; }
            echo -e "${yellow}已经切换到测试版${reset}"
            echo -e "${yellow}等待 3 秒后重启生效${reset}"
            sleep 3s
            systemctl restart mihomo
            echo -e "${yellow}当前软件版本${reset}：【 ${green}${version}${reset} 】"
            start_menu
            ;;
        2)
            if [[ "$download_version_type" == "latest" ]]; then
                echo -e "${yellow}当前已经是正式版，无需重复操作${reset}"
                start_menu
                return
            fi
            echo -e "${yellow}准备切换到正式版${reset}"
            download_latest_version || { echo -e "${red}获取正式版版本失败，请检查网络或源地址！${reset}"; exit 1; } 
            download_latest_mihomo || { echo -e "${red}正式版安装失败${reset}"; exit 1; }
            echo -e "${yellow}已经切换到正式版${reset}"
            echo -e "${yellow}等待 3 秒后重启生效${reset}"
            sleep 3s
            systemctl restart mihomo
            echo -e "${yellow}当前软件版本${reset}：【 ${green}v${version}${reset} 】"
            start_menu
            ;;
        *)
            echo -e "${red}无效选项，请输入 1 或 2${reset}"
            exit 1
            ;;
    esac
}

menu() {
    clear
    echo "================================="
    echo -e "${green}欢迎使用 mihomo 一键脚本 Beta 版${reset}"
    echo -e "${green}作者：${yellow}ChatGPT JK789${reset}"
    echo -e "${red}更换订阅说明：${reset}"
    echo -e "${red} 1. 更换订阅不能保存原有机场订阅"
    echo -e "${red} 2. 需要全部重新添加机场订阅${reset}"
    echo "================================="
    echo -e "${green} 0${reset}. 更新脚本"
    echo -e "${green}10${reset}. 退出脚本"
    echo -e "${green}20${reset}. 更换订阅"
    echo "---------------------------------"
    echo -e "${green} 1${reset}. 安装 mihomo"
    echo -e "${green} 2${reset}. 更新 mihomo"
    echo -e "${green} 3${reset}. 卸载 mihomo"
    echo "---------------------------------"
    echo -e "${green} 4${reset}. 启动 mihomo"
    echo -e "${green} 5${reset}. 停止 mihomo"
    echo -e "${green} 6${reset}. 重启 mihomo"
    echo "---------------------------------"
    echo -e "${green} 7${reset}. 添加开机自启"
    echo -e "${green} 8${reset}. 关闭开机自启"
    echo -e "${green} 9${reset}. 切换软件版本"
    echo "================================="
    show_status
    echo "================================="
    read -p "请输入上面选项：" input
    case "$input" in
        1) install_mihomo ;;
        2) update_mihomo ;;
        3) uninstall_mihomo ;;
        4) start_mihomo ;;
        5) stop_mihomo ;;
        6) restart_mihomo ;;
        7) enable_mihomo ;;
        8) disable_mihomo ;;
        9) switch_version ;;
        20) config_mihomo ;;
        10) exit 0 ;;
        0) update_shell ;;
        *) echo -e "${red}无效选项，请重新选择${reset}" 
           exit 1 ;;
    esac
}

menu