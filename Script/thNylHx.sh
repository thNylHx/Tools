#!/bin/bash

## bash <(curl -fsSL https://raw.githubusercontent.com/thNylHx/Tools/main/Script/thNylHx.sh)

set -e -o pipefail

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo "请以 root 权限运行此脚本。" 
   exit 1
fi

echo "================================="
echo "欢迎使用一键脚本"
echo "作者：thNylHx"
echo "请保证科学上网已经开启"
echo "安装过程中可以按 ctrl+c 强制退出"
echo "================================="

echo " 1. 安装 docker 和 docker-compose"
echo " 2. 安装 青龙面板"
echo " 3. 安装 AdGuardHome"
echo "---------------------------------"
echo " 4. 安装 mihomo"
echo " 5. 安装 VMESS"
echo " 6. 安装 Trojan-go"
echo " 7. 安装 Shadowsocks-Rust"
echo "---------------------------------"
echo " 8. 一键开启 ROOT 权限"
echo " 9. 一键更换软件源（Debian 12）"
echo "---------------------------------"
echo " 0. 退出一键安装脚本"
echo "================================="
read -p "输入数字选择[0-9]: " action

case $action in
    1)
    echo "开始安装 docker 和 docker-compose"
    bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/DockerInstallation.sh)
    echo "docker 和 docker-compose 安装完成，请返回上级菜单!"
    ;;

    2)
    echo "开始安装 青龙面板"
    # 这里应该插入安装青龙面板的命令
    echo "青龙面板 安装完成，请返回上级菜单!"
    ;;

    3)
    echo "开始安装 AdGuardHome"
    # 这里应该插入安装 AdGuardHome 的命令
    echo "AdGuardHome 安装完成，请返回上级菜单!"
    ;;

    4)
    echo "开始安装 mihomo"
    # 这里应该插入安装 mihomo 的命令
    echo "mihomo 安装完成，请返回上级菜单!"
    ;;

    5)
    echo "开始安装 VMESS"
    # 这里应该插入安装 VMESS 的命令
    echo "VMESS 安装完成，请返回上级菜单!"
    ;;

    6)
    echo "开始安装 Trojan-go"
    # 这里应该插入安装 Trojan-go 的命令
    echo "Trojan-go 安装完成，请返回上级菜单!"
    ;;

    7)
    echo "开始安装 Shadowsocks-Rust"
    # 这里应该插入安装 Shadowsocks-Rust 的命令
    echo "Shadowsocks-Rust 安装完成，请返回上级菜单!"
    ;;

    8)
    echo "开始一键开启 ROOT 权限"
    # 这里应该插入开启 ROOT 权限的命令
    echo "ROOT 权限开启完成，请返回上级菜单!"
    ;;

    9)
    echo "开始一键更换软件源（Debian 12）"
    # 这里应该插入更换软件源的命令
    echo "软件源更换完成，请返回上级菜单!"
    ;;

    0)
    echo "退出一键安装脚本"
    exit 0
    ;;

    *)
    echo "无效选择，请输入 [0-9] 之间的数字。"
    ;;
esac
