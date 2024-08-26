#!/bin/bash
#!name = mihomo 一键脚本 Beta 全新版
#!desc = 支持，安装、更新、卸载等
#!date = 2024-08-26 20:00
#!author = AdsJK567 ChatGPT

set -e -o pipefail

# 定义颜色代码
## 红色
Red="\033[31m"
## 绿色 
Green="\033[32m"
## 黄色
Yellow="\033[33m"
## 蓝色
Blue="\033[34m"
## 洋红
Magenta="\033[35m"
## 青色
Cyan="\033[36m"
## 白色
White="\033[37m"
## 黑色
Reset="\033[0m"

# 定义脚本版本
Sh_ver="1.5.5"

# 定义全局变量
## 总文件夹路径
FOLDERS="/root/mihomo"
## 文件路径
FILE="/root/mihomo/mihomo"
## 管理面板文件夹路径
WEB_SERVICES="/root/mihomo/ui"
## 系统文件夹路径
SYSCTL_CONF="/etc/sysctl.conf"
## 配置文件夹路径
CONFIG_FILE="/root/mihomo/config.yaml"
## 版本文件夹路径
VERSION_FILE="/root/mihomo/version.txt"
## 系统服务配置文件夹路径
SYSTEM_FILE="/etc/systemd/system/mihomo.service"

#  GitHub 链接和 CDN 链接
## 获取脚本版本和脚本下载路径
SCRIPT_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Script/mihomo-install.sh"
CDN_SCRIPT_URL="https://gh-proxy.com/https://raw.githubusercontent.com/AdsJK567/Tools/main/Script/mihomo-install.sh"
## 获取软件版本路径
VERSION_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt"
CDN_VERSION_URL="https://gh-proxy.com/https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt"
## 软件下载地址路径
DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${FILENAME}"
CDN_DOWNLOAD_URL="https://gh-proxy.com/https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${FILENAME}"
## 管理面板下载路径
GIT_URL="https://github.com/metacubex/metacubexd.git"
CDN_GIT_URL="https://gh-proxy.com/https://github.com/metacubex/metacubexd.git"
## 系统服务配置文件下载路径
SYSTEM_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Service/mihomo.service"
CDN_SYSTEM_URL="https://gh-proxy.com/https://raw.githubusercontent.com/AdsJK567/Tools/main/Service/mihomo.service"
## 
CONFIG_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Config/mihomo.yaml"
CDN_CONFIG_URL="https://gh-proxy.com/https://raw.githubusercontent.com/AdsJK567/Tools/main/Config/mihomo.yaml"

# 获取版本信息
Get_version(){
    # 获取版本信息
    VERSION=$(curl -sSL "$VERSION_URL")
    # 判断是否成功获取版本信息
    if [ -z "$VERSION" ]; then
        echo -e "${Red}主链接获取版本信息失败，尝试使用 CDN 获取${Reset}"
        # 从 CDN 获取版本信息
        VERSION=$(curl -sSL "$CDN_VERSION_URL")
        # 再次判断是否成功获取版本信息
        if [ -z "$VERSION" ]; then
            echo -e "${Red}CDN 获取版本信息失败，无法继续${Reset}"
            exit 1
        fi
    fi
}

# 获取新版本信息
Get_latest_version(){
    # 获取版本信息
    LATEST_VERSION=$(curl -sSL "$VERSION_URL")
    # 判断是否成功获取版本信息
    if [ -z "$LATEST_VERSION" ]; then
        echo -e "${Red}主链接获取版本信息失败，尝试使用 CDN 获取${Reset}"
        # 从 CDN 获取版本信息
        LATEST_VERSION=$(curl -sSL "$CDN_VERSION_URL")
        # 再次判断是否成功获取版本信息
        if [ -z "$LATEST_VERSION" ]; then
            echo -e "${Red}CDN 获取版本信息失败，无法继续${Reset}"
            exit 1
        fi
    fi
}

# 获取当前安装版本信息
Get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "mihomo 未安装"
    fi
}

# 下载软件
Download(){
    # 尝试从主链接下载
    wget -t 3 -T 30 "$DOWNLOAD_URL" -O "$FILENAME" || {
      echo -e "${Red}主链接下载失败，尝试使用 CDN${Reset}"
      # 尝试从 CDN 下载
      wget -t 3 -T 30 "$CDN_DOWNLOAD_URL" -O "$FILENAME" || {
          echo -e "${Red}CDN 下载失败，更新中止${Reset}"
          exit 1
      }
    }
}

# 更新下载软件
Download_latest(){
    # 尝试从主链接下载
    wget -t 3 -T 30 "$DOWNLOAD_URL" -O "$LATEST_VERSION" || {
      echo -e "${Red}主链接下载失败，尝试使用 CDN${Reset}"
      # 尝试从 CDN 下载
      wget -t 3 -T 30 "$CDN_DOWNLOAD_URL" -O "$LATEST_VERSION" || {
          echo -e "${Red}CDN 下载失败，更新中止${Reset}"
          exit 1
      }
    }
}

# 获取当前本机 IP 地址
GetLocal_ip(){
    # 获取本机的 IPv4 地址
    ipv4=$(ip addr show $(ip route | grep default | awk '{print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    # 获取本机的 IPv6 地址
    ipv6=$(ip addr show $(ip route | grep default | awk '{print $5}') | grep 'inet6 ' | awk '{print $2}' | cut -d/ -f1)
}

# 返回主菜单
Start_Main() {
    echo && echo -n -e "${Red}* 按回车返回主菜单 *${Reset}" && read temp
    Main
}

# 检查是否安装
Check_install(){
    if [ ! -f "$FILE" ]; then
        echo -e "${Red}mihomo 未安装${Reset}"
        Start_Main
    fi
}

# 检查服务状态
Check_status() {
    if pgrep -x "mihomo" > /dev/null; then
        status="running"
    else
        status="stopped"
    fi
}


# 显示当前脚本、是否设置开机自启和服务状态
Show_Status() {
    if [ ! -f "$FILE" ]; then
        status="${Red}未安装${Reset}"
        run_status="${Red}未运行${Reset}"
        auto_start="${Red}未设置${Reset}"
    else
        Check_status
        if [ "$status" == "running" ]; then
            status="${Green}已安装${Reset}"
            run_status="${Green}运行中${Reset}"
        else
            status="${Green}已安装${Reset}"
            run_status="${Red}未运行${Reset}"
        fi
        if systemctl is-enabled mihomo.service &>/dev/null; then
            auto_start="${Green}已设置${Reset}"
        else
            auto_start="${Red}未设置${Reset}"
        fi
    fi
    # 输出状态
    echo -e "脚本版本：${Green}${Sh_ver}${Reset}"
    echo -e "安装状态：${status}"
    echo -e "运行状态：${run_status}"
    echo -e "开机自启：${auto_start}"
}

# 获取当前架构
Get_the_schema(){
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='amd64';;
        'x86' | 'i686' | 'i386')     ARCH='386';;
        'aarch64' | 'arm64') ARCH='arm64';;
        'armv7l')   ARCH='armv7';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red}不支持的架构：${ARCH_RAW}${Reset}"; exit 1;;
    esac
}

# 检查和设置 IP 转发参数
Check_ip_forward() {
    # 要检查的设置
    local IPV4_FORWARD="net.ipv4.ip_forward = 1"
    # 检查是否已存在 net.ipv4.ip_forward = 1
    if grep -q "^${IPV4_FORWARD}$" "$SYSCTL_CONF"; then
        # 不执行 sysctl -p，因为设置已经存在
        return
    fi
    # 如果设置不存在，则添加并执行 sysctl -p
    echo "$IPV4_FORWARD" >> "$SYSCTL_CONF"
    # 立即生效
    sysctl -p
    echo -e "${Green}IP 转发开启成功${Reset}"
}

# 启动
Start() {
    # 检查是否安装
    Check_install
    if systemctl is-active --quiet mihomo; then
        echo -e "${Green}mihomo 正在运行中${Reset}"
        Start_Main
    fi
    echo -e "${Green}mihomo 准备启动中${Reset}"
    # 重新加载
    systemctl enable mihomo
    # 启动服务
    if systemctl start mihomo; then
        echo -e "${Green}mihomo 启动命令已发出${Reset}"
    else
        echo -e "${Red}mihomo 启动失败${Reset}"
        exit 1
    fi
    # 等待服务启动
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet mihomo; then
        echo -e "${Green}mihomo 启动成功${Reset}"
    else
        echo -e "${Red}mihomo 启动失败${Reset}"
        exit 1
    fi
    Start_Main
}

# 停止
Stop() {
    # 检查是否安装
    Check_install
    # 检查是否运行
    if ! systemctl is-active --quiet mihomo; then
        echo -e "${Green}mihomo 已经停止${Reset}"
        exit 0
    fi
    echo -e "${Green}mihomo 准备停止中${Reset}"
    # 尝试停止服务
    if systemctl stop mihomo; then
        echo -e "${Green}mihomo 停止命令已发出${Reset}"
    else
        echo -e "${Red}mihomo 停止失败${Reset}"
        exit 1
    fi
    # 等待服务启动
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet mihomo; then
        echo -e "${Red}mihomo 停止失败${Reset}"
        exit 1
    else
        echo -e "${Green}mihomo 停止成功${Reset}"
    fi
    Start_Main
}

# 重启
Restart() {
    # 检查是否安装
    Check_install
    echo -e "${Green}mihomo 准备重启中${Reset}"
    # 重启服务
    if systemctl restart mihomo; then
        echo -e "${Green}mihomo 重启命令已发出${Reset}"
    else
        echo -e "${Red}mihomo 重启失败${Reset}"
        exit 1
    fi
    # 等待服务启动
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet mihomo; then
        echo -e "${Green}mihomo 重启成功${Reset}"
    else
        echo -e "${Red}mihomo 启动失败${Reset}"
        exit 1
    fi
    Start_Main
}

# 卸载
Uninstall() {
    # 检查是否安装
    Check_install
    echo -e "${Green}mihomo 开始卸载${Reset}"
    echo -e "${Green}mihomo 卸载命令已发出${Reset}"
    # 停止服务
    systemctl stop mihomo.service 2>/dev/null || { echo -e "${Red}停止 mihomo 服务失败${Reset}"; exit 1; }
    systemctl disable mihomo.service 2>/dev/null || { echo -e "${Red}禁用 mihomo 服务失败${Reset}"; exit 1; }
    # 删除服务文件
    rm -f "$SYSTEM_FILE" || { echo -e "${Red}删除服务文件失败${Reset}"; exit 1; }
    # 删除相关文件夹
    rm -rf "$FOLDERS" || { echo -e "${Red}删除相关文件夹失败${Reset}"; exit 1; }
    # 重新加载 systemd
    systemctl daemon-reload || { echo -e "${Red}重新加载 systemd 配置失败${Reset}"; exit 1; }
    # 等待服务停止
    sleep 3s
    # 检查卸载是否成功
    if [ ! -f "$SYSTEM_FILE" ] && [ ! -d "$FOLDERS" ]; then
        echo -e "${Green}mihomo 卸载完成${Reset}"
    else
        echo -e "${Red}卸载过程中出现问题，请手动检查${Reset}"
    fi
    exit 0
}

# 更新脚本
Update_Shell() {
    # 获取当前版本
    echo -e "${Green}开始检查是否有更新${Reset}"
    # 获取脚本版本信息
    Sh_new_ver=$(wget --no-check-certificate -qO- "$SCRIPT_URL" | grep 'Sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    # 判断是否成功获取脚本版本信息
    if [ -z "$Sh_new_ver" ]; then
        echo -e "${Red}主链接获取脚本版本信息失败，尝试使用 CDN 获取${Reset}"
        # 从CDN获取脚本版本信息
        Sh_new_ver=$(wget --no-check-certificate -qO- "$CDN_SCRIPT_URL" | grep 'Sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
        # 再次判断是否成功获取脚本版本信息
        if [ -z "$Sh_new_ver" ]; then
            echo -e "${Red}CDN 获取脚本版本信息失败，无法继续${Reset}"
            exit 1
        fi
    fi
    # 最新版本无需更新
    if [ "$Sh_ver" == "$Sh_new_ver" ]; then
        echo -e "当前版本：[ ${Green}${Sh_ver}${Reset} ]"
        echo -e "最新版本：[ ${Green}${Sh_new_ver}${Reset} ]"
        echo -e "${Green}当前已是最新版本，无需更新${Reset}"
        Start_Main
    fi
    echo -e "${Green}检查到已有新版本${Reset}"
    echo -e "当前版本：[ ${Green}${Sh_ver}${Reset} ]"
    echo -e "最新版本：[ ${Green}${Sh_new_ver}${Reset} ]"
    # 开始更新
    while true; do
        read -p "是否升级到最新版本？(y/n): " confirm
        case $confirm in
            [Yy]* )
                # 尝试从主链接下载
                echo -e "开始下载最新版本 [ ${Green}${Sh_new_ver}${Reset} ]"
                wget -O mihomo-install.sh --no-check-certificate "$SCRIPT_URL" || {
                    echo -e "${Red}主链接下载失败，尝试使用 CDN${Reset}"
                    # 尝试从 CDN 下载
                    wget -O mihomo-install.sh --no-check-certificate "$CDN_SCRIPT_URL" || {
                        echo -e "${Red}CDN 下载失败，更新中止${Reset}"
                        exit 1
                    }
                }
                # 设置脚本为可执行
                chmod +x mihomo-install.sh
                echo -e "更新完成，当前版本已更新为 [ ${Green}${Sh_new_ver}${Reset} ]"
                echo -e "5 秒后执行新脚本"
                sleep 5s
                # 执行新脚本
                bash mihomo-install.sh
                break
                ;;
            [Nn]* )
                echo -e "${Red}更新已取消${Reset}"
                exit 1
                ;;
            * )
                echo -e "${Red}无效的输入，请输入 y 或 n${Reset}"
                ;;
        esac
    done
    Start_Main
}

# 安装
Install() {
    # 检查是否安装 
    if [ -f "$FILE" ]; then
        echo -e "${Green}mihomo 已经安装${Reset}"
        Start_Main
    fi
    # 更新系统
    apt update && apt dist-upgrade -y
    # 安装插件
    apt-get install jq unzip curl git wget vim dnsutils openssl coreutils grep gawk iptables gunzip -y
    # 创建文件夹
    mkdir -p $FOLDERS && cd $FOLDERS || { echo -e "${Red}创建或进入 $FOLDERS 目录失败${Reset}"; exit 1; }
    # 获取架构
    Get_the_schema
    echo -e "当前架构：[ ${Green}${ARCH_RAW}${Reset} ]"
    # 获取版本信息
    Get_version
    # 输出获取到的版本信息
    echo -e "当前版本：[ ${Green}${VERSION}${Reset} ]"
    # 构造文件名
    case "$ARCH" in
        'arm64' | 'armv7' | 's390x' | '386') FILENAME="mihomo-linux-${ARCH}-${VERSION}.gz";;
        'amd64') FILENAME="mihomo-linux-${ARCH}-compatible-${VERSION}.gz";;
        *)       echo -e "不支持的架构：[ ${Red}${ARCH}${Reset} ]"; exit 1;;
    esac
    # 开始下载
    Download
    echo -e "[ ${Green}${VERSION}${Reset} ] 下载完成，开始安装"
    # 解压文件
    gunzip "$FILENAME" || { echo -e "${Red}解压失败${Reset}"; exit 1; }
    # 重命名
    if [ -f "mihomo-linux-${ARCH}-${VERSION}" ]; then
        mv "mihomo-linux-${ARCH}-${VERSION}" mihomo
    elif [ -f "mihomo-linux-${ARCH}-compatible-${VERSION}" ]; then
        mv "mihomo-linux-${ARCH}-compatible-${VERSION}" mihomo
    else
        echo -e "${Red}找不到解压后的文件${Reset}"
        exit 1
    fi
    # 授权
    chmod 755 mihomo
    # 记录版本信息
    echo "$VERSION" > "$VERSION_FILE"
    # 管理面板下载
    echo -e "${Green}开始下载 mihomo 管理面板${Reset}"
    # 尝试从主链接克隆
    git clone "$GIT_URL" -b gh-pages "$WEB_SERVICES" || {
        echo -e "${Red}主链接克隆失败，尝试使用 CDN${Reset}"
        # 尝试从 CDN 克隆
        git clone "$CDN_GIT_URL" -b gh-pages "$WEB_SERVICES" || {
            echo -e "${Red}CDN 克隆失败，更新中止${Reset}"
            exit 1
        }
    }
    # 下载系统配置文件
    echo -e "${Green}开始下载 mihomo 的 Service 系统配置${Reset}"
    # 尝试从主链接下载
    wget -O "$SYSTEM_FILE" "$SYSTEM_URL" && chmod 755 "$SYSTEM_FILE" || {
        echo -e "${Red}主链接下载失败，尝试使用 CDN${Reset}"
        # 尝试从 CDN 下载
        wget -O "$SYSTEM_FILE" "$CDN_SYSTEM_URL" && chmod 755 "$SYSTEM_FILE" || {
            echo -e "${Red}CDN 下载失败，更新中止${Reset}"
            exit 1
        }
    }
    echo -e "${Green}mihomo 安装完成，开始配置${Reset}"
    # 开始配置 config 文件
    Configure
}

# 更新
Update() {
    # 检查是否安装
    Check_install
    echo -e "${Green}开始检查是否有更新${Reset}"
    cd $FOLDERS
    # 获取当前版本
    CURRENT_VERSION=$(Get_current_version)
    # 获取新版本信息
    Get_latest_version
    # 开始更新
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo -e "当前版本：[ ${Green}${CURRENT_VERSION}${Reset} ]"
        echo -e "最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
        echo -e "${Green}当前已是最新版本，无需更新${Reset}"
        Start_Main
    fi
    echo -e "${Green}检查到已有新版本${Reset}"
    echo -e "当前版本：[ ${Green}${CURRENT_VERSION}${Reset} ]"
    echo -e "最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
    while true; do
        read -p "是否升级到最新版本？(y/n)：" confirm
        case $confirm in
            [Yy]* )
                # 获取架构
                Get_the_schema
                # 构造文件名
                case "$ARCH" in
                    'arm64' | 'armv7' | 's390x' | '386') FILENAME="mihomo-linux-${ARCH}-${LATEST_VERSION}.gz";;
                    'amd64') FILENAME="mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}.gz";;
                    *)       FILENAME="mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}.gz";;
                esac
                # 开始下载
                Download_latest
                echo -e "[ ${Green}${LATEST_VERSION}${Reset} ] 下载完成，开始更新"
                # 解压文件
                gunzip "$FILENAME" || { echo -e "${Red}解压失败${Reset}"; exit 1; }
                # 重命名
                if [ -f "mihomo-linux-${ARCH}-${LATEST_VERSION}" ]; then
                    mv "mihomo-linux-${ARCH}-${LATEST_VERSION}" mihomo
                elif [ -f "mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}" ]; then
                    mv "mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}" mihomo
                else
                    echo -e "${Red}找不到下载后的文件${Reset}"
                    exit 1
                fi
                # 授权
                chmod 755 mihomo
                # 更新版本信息
                echo "$LATEST_VERSION" > "$VERSION_FILE"
                # 重新加载 systemd
                systemctl daemon-reload
                # 重启 mihomo 服务
                systemctl restart mihomo
                echo -e "更新完成，当前版本已更新为：[ ${Green}${LATEST_VERSION}${Reset} ]"
                # 检查并显示服务状态
                if systemctl is-active --quiet mihomo; then
                    echo -e "当前状态：[ ${Green}运行中${Reset} ]"
                else
                    echo -e "当前状态：[ ${Red}未运行${Reset} ]"
                    Start_Main
                fi
                Start_Main
                ;;
            [Nn]* )
                echo -e "${Red}更新已取消 ${Reset}"
                Start_Main
                ;;
            * )
                echo -e "${Red}无效的输入，请输入 y 或 n ${Reset}"
                ;;
        esac
    done
    Start_Main
}

# 配置
Configure() {
    # 检查是否安装
    Check_install
    # 下载配置文件
    wget -O "$CONFIG_FILE" "$CONFIG_URL" || {
        echo -e "${Red}主链接下载配置文件失败，尝试使用 CDN${Reset}"
        # 尝试从 CDN 下载配置文件
        wget -O "$CONFIG_FILE" "$CDN_CONFIG_URL" || {
            echo -e "${Red}CDN 下载配置文件失败，更新中止${Reset}"
            exit 1
        }
    }
    # 获取用户输入的机场数量，默认为 1，且限制为 5 个以内
    while true; do
        read -p "请输入需要配置的机场数量（默认 1 个，最多 5 个）：" airport_count
        airport_count=${airport_count:-1}
        # 验证输入是否为 1 到 5 之间的正整数
        if [[ "$airport_count" =~ ^[0-9]+$ ]] && [ "$airport_count" -ge 1 ] && [ "$airport_count" -le 5 ]; then
            break
        else
            echo -e "\033[31m无效的数量，请输入 1 到 5 之间的正整数。\033[0m"
        fi
    done
    # 读取配置文件
    echo -e "${Green}读取配置文件${Reset}"
    # 初始化 proxy-providers 部分
    proxy_providers="proxy-providers:"
    # 动态添加机场
    for ((i=1; i<=airport_count; i++))
    do
        read -p "请输入第 $i 个机场的订阅连接：" airport_url
        read -p "请输入第 $i 个机场的名称：" airport_name
        
        proxy_providers="$proxy_providers
  # 机场$i
  Airport_0$i:
    <<: *pr
    url: \"$airport_url\"
    override:
      additional-prefix: \"[$airport_name]\""
    done
    # 修改配置文件
    echo -e "${Green}修改配置文件${Reset}"
    # 写入配置文件
    echo -e "${Green}写入配置文件${Reset}"
    # 使用 awk 将 proxy-providers 插入到指定位置
    awk -v providers="$proxy_providers" '
    /^# 机场订阅/ {
        print
        print providers
        next
    }
    { print }
    ' "$CONFIG_FILE" > temp.yaml && mv temp.yaml "$CONFIG_FILE"
    # 验证修改后的配置文件格式
    echo -e "${Green}验证修改后的配置文件格式${Reset}"
    # 提示保存位置
    echo -e "${Green}mihomo 配置已完成并保存到 ${CONFIG_FILE} 文件夹${Reset}"
    echo -e "${Green}mihomo 配置完成，正在启动中${Reset}"
    # 重新加载 systemd
    systemctl daemon-reload
    # 立即启动 mihomo 服务
    systemctl start mihomo
    # # 检查 mihomo 服务状态
    # systemctl status mihomo
    echo -e "${Green}已设置开机自启${Reset}"
    # 设置开机启动
    systemctl enable mihomo
    # 调用函数获取
    GetLocal_ip
    # 引导语
    echo -e "恭喜你，你的 mihomo 已经配置完成"
    echo -e "使用 ${Green}http://$ipv4:9090/ui${Reset} 访问你的 mihomo 管理面板面板"
    # 返回主菜单
    Start_Main
}

# 主菜单
Main() {
    clear
    echo "================================="
    echo -e "${Green}欢迎使用 mihomo 一键脚本 Beta 版${Reset}"
    echo -e "${Green}作者：${Reset}${Red}AdsJK567${Reset}"
    echo -e "${Green}请保证科学上网已经开启${Reset}"
    echo -e "${Green}安装过程中可以按 ctrl+c 强制退出${Reset}"
    echo "================================="
    echo -e "${Green}0${Reset}、更新脚本"
    echo "---------------------------------"
    echo -e "${Green}1${Reset}、安装 mihomo"
    echo -e "${Green}2${Reset}、更新 mihomo"
    echo -e "${Green}3${Reset}、配置 mihomo"
    echo -e "${Green}4${Reset}、卸载 mihomo"
    echo "---------------------------------"
    echo -e "${Green}5${Reset}、启动 mihomo"
    echo -e "${Green}6${Reset}、停止 mihomo"
    echo -e "${Green}7${Reset}、重启 mihomo"
    echo -e "${Green}8${Reset}、退出脚本"
    echo "================================="
    Show_Status
    echo "================================="
    read -p "请输入选项[0-8]：" num
    case "$num" in
        1) Check_ip_forward; Install ;;
        2) Update ;;
        3) Configure ;;
        4) Uninstall ;;
        5) Start ;;
        6) Stop ;;
        7) Restart ;;
        8) exit 0 ;;
        0) Update_Shell ;;
        *) echo -e "${Red}无效选项，请重新选择${Reset}" 
           exit 1 ;;
    esac
}

# 启动主菜单
Main
