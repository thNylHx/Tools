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
echo "安装过程中可以按ctrl+c强制退出"
echo "================================="

echo " 1、 安装 docker 和 docker-compose"
echo " 2、 安装 青龙面板"
echo " 3、 安装 AdGuardHome"
echo "---------------------------------"
echo " 4、 安装 Trojan-go"
echo " 5、 安装 VMESS"
echo " 6、 安装 mihomo"
echo "---------------------------------"
echo " 7、一键更换软件源（Debian 12）"
echo " 8、一键开启 ROOT 权限"
echo "---------------------------------"
echo " 0、 退出一键安装脚本"
echo "================================="
read -p "输入数字选择[0-8]: " action


case $action in
    1)
    echo "开始安装 docker 和 docker-compose"
    bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/DockerInstallation.sh)



