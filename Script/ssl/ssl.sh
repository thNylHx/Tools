#!/bin/bash

# === 脚本信息 ===
echo "----------------------------------------------------"
echo "SSL 证书安装脚本 - 使用 acme.sh 通过 Cloudflare DNS 申请证书"
echo "----------------------------------------------------"

# === 检查是否以 root 用户运行 ===
if [ "$(id -u)" -ne 0 ]; then
  echo "错误：请使用 root 权限运行此脚本！"
  exit 1
fi

# === 安装前检查 ===
echo "正在检查系统更新和安装依赖..."

# 更新包列表并安装依赖
apt update -y
apt install -y socat curl

echo "正在安装 acme.sh..."
curl https://get.acme.sh | sh

# 设置环境变量
echo "正在设置 Cloudflare 环境变量..."
export CF_Token="$Token"
export CF_Account_ID="$Account_ID"

# 确保 acme.sh 命令可用
ACME_PATH="/root/.acme.sh/acme.sh"
if [ ! -f "$ACME_PATH" ]; then
  echo "错误：acme.sh 安装失败，找不到 $ACME_PATH"
  exit 1
fi

# 选择证书颁发机构
$ACME_PATH --set-default-ca --server letsencrypt

# === 用户输入部分 ===
# 获取 Cloudflare API token、账号 ID 和域名
read -p "请输入你的 Cloudflare API Token: " Token
read -p "请输入你的 Cloudflare 账号 ID: " Account_ID
read -p "请输入你要申请证书的域名: " DOMAIN

# 设置 Cloudflare API token 和账号 ID
echo "正在设置 Cloudflare 环境变量..."
export CF_Token="$Token"
export CF_Account_ID="$Account_ID"

# 安装证书
echo "正在申请证书..."
$ACME_PATH --issue --dns dns_cf -d "$DOMAIN"

# 安装证书到指定目录
echo "正在安装证书..."
mkdir -p /root/ssl
$ACME_PATH --install-cert -d "$DOMAIN" \
  --key-file /root/ssl/server.key \
  --fullchain-file /root/ssl/server.crt

# === 完成提示 ===
echo "----------------------------------------------------"
echo "证书安装成功！证书已安装至 /root/ssl/ 目录。"
echo "----------------------------------------------------"
