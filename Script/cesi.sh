#!/bin/bash

set -e -o pipefail

# 定义颜色代码
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}请以 root 权限运行此脚本。${NC}" 
   exit 1
fi

# 检查 V2ray 服务状态
check_v2ray_status() {
    if systemctl is-active --quiet v2ray; then
        echo -e "${GREEN}正在运行。${NC}"
    else
        echo -e "${RED}未运行。${NC}"
    fi
}

# 检查 V2ray 是否设置为开机启动
check_v2ray_enable() {
    if systemctl is-enabled --quiet v2ray; then
        echo -e "${GREEN}已设置。${NC}"
    else
        echo -e "${RED}未设置。${NC}"
    fi
}

# 设置 V2ray 配置信息
set_config() {
    echo "请选择配置文件类型："
    echo "=============================="
    echo -e " ${GREEN}1${NC}、 vmess+tcp"
    echo -e " ${GREEN}2${NC}、 vmess+ws"
    echo -e " ${GREEN}3${NC}、 vmess+tcp+tls（需要域名）"
    echo -e " ${GREEN}4${NC}、 vmess+ws+tls（需要域名）"
    echo "=============================="
    read -p "输入数字选择 (1-4): " config_choice

    # 端口处理
    read -p "请输入监听端口 (10000-65000之间, 留空以生成随机端口): " PORT
    if [[ -z "$PORT" ]]; then
        PORT=$(shuf -i 10000-65000 -n 1)
        echo -e "随机生成的监听端口: ${GREEN}$PORT${NC}"
    elif [[ "$PORT" -lt 10000 || "$PORT" -gt 65000 ]]; then
        echo -e "${RED}端口号必须在10000到65000之间。${NC}"
        exit 1
    fi

    # UUID处理
    read -p "请输入 V2Ray UUID (留空以生成随机UUID): " UUID
    if [[ -z "$UUID" ]]; then
        if command -v uuidgen >/dev/null 2>&1; then
            UUID=$(uuidgen)
        else
            UUID=$(cat /proc/sys/kernel/random/uuid)
        fi
        echo -e "随机生成的UUID: ${GREEN}$UUID${NC}"
    fi

    # WebSocket 路径处理
    WS_PATH=""
    if [[ $config_choice == 2 || $config_choice == 4 ]]; then
        read -p "请输入 WebSocket 路径（例如 v2ray，留空以生成随机路径）: " WS_PATH
        if [[ -z "$WS_PATH" ]]; then
            WS_PATH=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
            echo -e "生成的 WebSocket 路径: ${GREEN}${WS_PATH}${NC}"
        fi
    
        # 确保路径以 "/" 开头
        WS_PATH="${WS_PATH#/}"  # 移除可能存在的开头斜杠
        WS_PATH="/$WS_PATH"     # 确保路径以斜杠开头
    fi

    # 调试输出
    echo -e "配置类型: $config_choice"
    echo -e "端口: $PORT"
    echo -e "UUID: $UUID"
    echo -e "WebSocket 路径: $WS_PATH"

    # 创建配置文件
    case $config_choice in
        1)
        cat << EOF > /root/V2ray/config.json
{
  "inbounds": [
    {
      "port": $PORT, 
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "$UUID",  
            "alterId": 0
          }
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",  
      "settings": {}
    }
  ],
  "vmess-aead": true
}
EOF
        ;;
        2)
        cat << EOF > /root/V2ray/config.json
{
  "inbounds": [
    {
      "port": $PORT, 
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "$UUID",  
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$WS_PATH"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ],
  "vmess-aead": true
}
EOF
        ;;
        3)
        if [[ ! -f /root/V2ray/server.crt || ! -f /root/V2ray/server.key ]]; then
            echo -e "${RED}TLS 配置文件 server.crt 或 server.key 不存在，请先生成或上传证书文件。${NC}"
            exit 1
        fi

        cat << EOF > /root/V2ray/config.json
{
  "inbounds": [
    {
      "port": $PORT, 
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "$UUID",  
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/root/V2ray/server.crt", 
              "keyFile": "/root/V2ray/server.key" 
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ],
  "vmess-aead": true
}
EOF
        ;;
        4)
        if [[ ! -f /root/V2ray/server.crt || ! -f /root/V2ray/server.key ]]; then
            echo -e "${RED}TLS 配置文件 server.crt 或 server.key 不存在，请先生成或上传证书文件。${NC}"
            exit 1
        fi

        cat << EOF > /root/V2ray/config.json
{
  "inbounds": [
    {
      "port": $PORT, 
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "$UUID",  
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$WS_PATH"
        },
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/root/V2ray/server.crt", 
              "keyFile": "/root/V2ray/server.key" 
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ],
  "vmess-aead": true
}
EOF
    esac
}

# 查看当前 V2ray 配置
view_config() {
    if [[ -f /root/V2ray/config.json ]]; then
        echo -e "当前 V2ray 配置文件内容:"
        cat /root/V2ray/config.json
    else
        echo -e "${RED}配置文件不存在，请安装或配置 V2ray。${NC}"
    fi
}

# 主菜单
echo "V2ray 一键安装管理脚本"
echo "请选择操作："
echo "=============================="
echo -e " ${GREEN}1${NC}、 安装 V2ray"
echo -e " ${GREEN}2${NC}、 升级 V2ray"
echo -e " ${GREEN}3${NC}、 卸载 V2ray"
echo "=============================="
echo -e " ${GREEN}4${NC}、 重新启动 V2ray"
echo -e " ${GREEN}5${NC}、 重新加载 V2ray"
echo -e " ${GREEN}6${NC}、 设置开机启动 V2ray"
echo -e " ${GREEN}9${NC}、 设置 V2ray 配置信息"
echo -e " ${GREEN}10${NC}、 查看 V2ray 配置信息"
echo "=============================="
echo -e " ${GREEN}0${NC}、 退出一键安装脚本"
echo ""

# 显示 V2ray 的当前运行状态和开机自启状态
echo -e " 运行状态：$(check_v2ray_status)"
echo -e " 开机自启：$(check_v2ray_enable)"
echo ""

read -p "输入数字选择 [0-10]: " action

case $action in
    1)
    echo -e "${GREEN}开始安装 V2ray，请稍后...${NC}"
    mkdir -p /root/V2ray
    cd /root/V2ray

    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='64';;
        'x86' | 'i686' | 'i386')     ARCH='32';;
        'aarch64' | 'arm64') ARCH='arm64-v8a';;
        'armv7' | 'armv7l')   ARCH='arm32-v7a';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${RED}不支持的架构: ${ARCH_RAW}${NC}"; exit 1;;
    esac
    echo -e "${GREEN}当前设备架构: ${ARCH_RAW}${NC}"

    VERSION=$(curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" \
        | grep tag_name \
        | cut -d ":" -f2 \
        | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    echo -e "${GREEN}获取到的最新版本: ${VERSION}${NC}"

    echo -e "${GREEN}开始下载 v2ray-core${NC}"

    wget -P /root/V2ray "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip" || { echo -e "${RED}下载失败${NC}"; exit 1; }

    echo -e "${GREEN}v2ray-core 下载完成, 开始部署${NC}"

    unzip "v2ray-linux-${ARCH}.zip" && rm "v2ray-linux-${ARCH}.zip" || { echo -e "${RED}解压失败${NC}"; exit 1; }

    echo -e "${GREEN}配置 V2ray${NC}"
    set_config

    echo -e "${GREEN}V2ray 安装完成${NC}"
    systemctl daemon-reload
    systemctl start v2ray
    ;;

    2)
    echo -e "${GREEN}开始升级 V2ray，请稍后...${NC}"

    # 停止现有的 V2ray 服务
    systemctl stop v2ray

    # 获取当前系统架构
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='64';;
        'x86' | 'i686' | 'i386')     ARCH='32';;
        'aarch64' | 'arm64') ARCH='arm64-v8a';;
        'armv7' | 'armv7l')   ARCH='arm32-v7a';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${RED}不支持的架构: ${ARCH_RAW}${NC}"; exit 1;;
    esac
    echo -e "${GREEN}当前设备架构: ${ARCH_RAW}${NC}"

    # 获取最新版本
    VERSION=$(curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" \
        | grep tag_name \
        | cut -d ":" -f2 \
        | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    echo -e "${GREEN}获取到的最新版本: ${VERSION}${NC}"

    echo -e "${GREEN}开始下载 v2ray-core${NC}"

    wget -P /root/V2ray "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip" || { echo -e "${RED}下载失败${NC}"; exit 1; }

    echo -e "${GREEN}v2ray-core 下载完成, 开始部署${NC}"

    unzip -o "v2ray-linux-${ARCH}.zip" && rm "v2ray-linux-${ARCH}.zip" || { echo -e "${RED}解压失败${NC}"; exit 1; }

    echo -e "${GREEN}V2ray 升级完成${NC}"
    systemctl daemon-reload
    systemctl start v2ray
    ;;

    3)
    echo -e "${GREEN}开始卸载 V2ray${NC}"

    # 停止服务
    systemctl stop v2ray

    # 删除服务文件和二进制文件
    systemctl disable v2ray
    rm -f /etc/systemd/system/v2ray.service
    rm -rf /root/V2ray

    echo -e "${GREEN}V2ray 卸载完成${NC}"
    ;;

    4)
    echo -e "${GREEN}开始重新启动 V2ray${NC}"
    systemctl restart v2ray
    ;;

    5)
    echo -e "${GREEN}开始重新加载 V2ray 配置${NC}"
    systemctl reload v2ray
    ;;

    6)
    echo -e "${GREEN}设置 V2ray 开机启动${NC}"
    systemctl enable v2ray
    ;;

    7)
    echo -e "${GREEN}查看 V2ray 启动状态${NC}"
    check_v2ray_status
    ;;

    8)
    echo -e "${GREEN}查看 V2ray 开机启动设置${NC}"
    check_v2ray_enable
    ;;

    9)
    echo -e "${GREEN}设置 V2ray 配置信息${NC}"
    set_config
    ;;

    10)
    echo -e "${GREEN}查看 V2ray 配置信息${NC}"
    view_config
    ;;

    0)
    echo -e "${GREEN}退出脚本${NC}"
    exit 0
    ;;

    *)
    echo -e "${RED}无效选项${NC}"
    exit 1
    ;;
esac

# 显示 V2ray 的当前运行状态和开机自启状态
echo -e " 运行状态：$(check_v2ray_status)"
echo -e " 开机自启：$(check_v2ray_enable)"
