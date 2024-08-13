#!/bin/bash

## bash <(curl -fsSL https://raw.githubusercontent.com/thNylHx/Tools/main/Script/thNylHx.sh)

set -e -o pipefail

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   TIME w "请以 root 权限运行此脚本。" 
   exit 1
fi



TIME w "================================="
TIME w "欢迎使用一键脚本"
TIME w "作者：thNylHx"
TIME w "请保证科学上网已经开启"
TIME w "安装过程中可以按ctrl+c强制退出"
TIME w "================================="

TIME w " 1、 安装 docker 和 docker-compose"
TIME w " 2、 安装 青龙面板"
TIME w " 3、 安装 AdGuardHome"
TIME w "---------------------------------"
TIME w " 4、 安装 Trojan-go"
TIME w " 5、 安装 VMESS"
TIME w " 6、 安装 mihomo"
TIME w "---------------------------------"
TIME w " 7、一键更换软件源（Debian 12）"
TIME w " 8、一键开启 ROOT 权限"
TIME w "---------------------------------"
TIME r " 0、 退出一键安装脚本"
TIME w "================================="
read -p "输入数字选择[0-8]: " action


case $action in
    1)
    TIME w "开始安装 docker 和 docker-compose"
    bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/DockerInstallation.sh)
    TIME g "docker 和 docker-compose 安装完成，请返回上级菜单!"
