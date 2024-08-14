#!/bin/bash

# 定义颜色代码
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"

# 定义脚本版本
sh_ver="1.0.4"

# V2Ray 可执行文件的路径
FILE="/root/V2ray/v2ray"

# 检查V2Ray服务状态
check_status() {
    if pgrep -x "v2ray" > /dev/null; then
        status="running"
    else
        status="stopped"
    fi
}

# 获取当前版本
get_current_version() {
    if [ -f "/root/V2ray/version.txt" ]; then
        cat /root/V2ray/version.txt
    else
        echo "未安装"
    fi
}

# 自签证书生成
generate_self_signed_cert() {
    echo -e "${Green_font_prefix}生成自签名证书中...${Font_color_suffix}"
    read -p "请输入伪装域名（例如：example.com）： " DOMAIN
    mkdir -p /root/V2ray/ssl
    openssl req -newkey rsa:2048 -nodes -keyout /root/V2ray/ssl/server.key -x509 -days 365 -out /root/V2ray/ssl/server.crt -subj "/C=CN/ST=Province/L=City/O=Organization/OU=Department/CN=$DOMAIN"
    echo -e "${Green_font_prefix}自签名证书生成完成！${Font_color_suffix}"
}

# 申请证书（假设使用 Cloudflare）
request_cert() {
    echo -e "${Green_font_prefix}申请证书中...${Font_color_suffix}"
    apt-get install -y certbot python3-certbot-dns-cloudflare
    read -p "请输入域名（用于证书申请）： " DOMAIN
    read -p "请输入 Cloudflare API 密钥： " CF_API_KEY
    cat <<EOF > /root/cloudflare.ini
dns_cloudflare_api_key = $CF_API_KEY
EOF
    chmod 600 /root/cloudflare.ini
    certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/cloudflare.ini -d "$DOMAIN"
    cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /root/V2ray/ssl/server.crt
    cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /root/V2ray/ssl/server.key
    echo -e "${Green_font_prefix}证书申请完成！${Font_color_suffix}"
}

# 安装V2Ray
Install() {
    echo -e "${Green_font_prefix}安装 V2Ray 中...${Font_color_suffix}"
    mkdir -p /root/V2ray
    cd /root/V2ray
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='64';;
        'x86' | 'i686' | 'i386')     ARCH='32';;
        'aarch64' | 'arm64') ARCH='arm64-v8a';;
        'armv7' | 'armv7l')   ARCH='arm32-v7a';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
    esac
    echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"

    VERSION=$(curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" \
        | grep tag_name \
        | cut -d ":" -f2 \
        | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    echo -e "${Green_font_prefix}获取到的最新版本: ${VERSION}${Font_color_suffix}"

    echo -e "${Green_font_prefix}开始下载 v2ray-core${Font_color_suffix}"
    wget -P /root/V2ray "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }

    echo -e "${Green_font_prefix}v2ray-core 下载完成, 开始部署${Font_color_suffix}"
    unzip "v2ray-linux-${ARCH}.zip" && rm "v2ray-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }

    echo -e "${Green_font_prefix}V2ray 安装完成${Font_color_suffix}"
    echo "$VERSION" > /root/V2ray/version.txt
    systemctl daemon-reload
    systemctl start v2ray

    # 提示用户选择配置
    echo -e "${Green_font_prefix}V2Ray 安装成功，请选择配置文件类型。${Font_color_suffix}"
    Set
}

# 更新V2Ray
Update() {
    echo -e "${Green_font_prefix}更新 V2Ray 中...${Font_color_suffix}"
    current_version=$(get_current_version)
    echo -e "${Green_font_prefix}当前安装版本: ${current_version}${Font_color_suffix}"

    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='64';;
        'x86' | 'i686' | 'i386')     ARCH='32';;
        'aarch64' | 'arm64') ARCH='arm64-v8a';;
        'armv7' | 'armv7l')   ARCH='arm32-v7a';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
    esac
    echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"

    VERSION=$(curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" \
        | grep tag_name \
        | cut -d ":" -f2 \
        | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

    if [ "$VERSION" != "$current_version" ]; then
        echo -e "${Green_font_prefix}获取到的最新版本: ${VERSION}${Font_color_suffix}"

        echo -e "${Green_font_prefix}开始下载 v2ray-core${Font_color_suffix}"
        wget -P /root/V2ray "https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/v2ray-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }

        echo -e "${Green_font_prefix}v2ray-core 下载完成, 开始部署${Font_color_suffix}"
        unzip -o "v2ray-linux-${ARCH}.zip" && rm "v2ray-linux-${ARCH}.zip" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }

        echo -e "${Green_font_prefix}V2ray 升级完成${Font_color_suffix}"
        echo "$VERSION" > /root/V2ray/version.txt
        systemctl daemon-reload
        systemctl start v2ray
    else
        echo -e "${Green_font_prefix}当前已是最新版本，无需更新。${Font_color_suffix}"
    fi
}

# 卸载V2Ray
Uninstall() {
    echo -e "${Red_font_prefix}卸载 V2Ray 中...${Font_color_suffix}"
    systemctl stop v2ray
    systemctl disable v2ray
    rm -rf /root/V2ray
    echo -e "${Red_font_prefix}V2Ray 已卸载。${Font_color_suffix}"
}

# 启动V2Ray
Start() {
    echo -e "${Green_font_prefix}启动 V2Ray...${Font_color_suffix}"
    systemctl start v2ray
    echo -e "${Green_font_prefix}V2Ray 已启动。${Font_color_suffix}"
}

# 停止V2Ray
Stop() {
    echo -e "${Red_font_prefix}停止 V2Ray...${Font_color_suffix}"
    systemctl stop v2ray
    echo -e "${Red_font_prefix}V2Ray 已停止。${Font_color_suffix}"
}

# 重启V2Ray
Restart() {
    echo -e "${Green_font_prefix}重启 V2Ray...${Font_color_suffix}"
    systemctl restart v2ray
    echo -e "${Green_font_prefix}V2Ray 重启完毕！${Font_color_suffix}"
}

# 设置配置信息
Set() {
    echo "请选择配置文件类型（默认选择 vmess+tcp）："
    echo "=============================="
    echo -e " ${Green_font_prefix}1${Font_color_suffix}、 vmess+tcp"
    echo -e " ${Green_font_prefix}2${Font_color_suffix}、 vmess+ws"
    echo -e " ${Green_font_prefix}3${Font_color_suffix}、 vmess+tcp+tls"
    echo -e " ${Green_font_prefix}4${Font_color_suffix}、 vmess+ws+tls"
    echo -e " ${Green_font_prefix}5${Font_color_suffix}、 退出"
    echo "=============================="
    read -p "请选择[1-5]: " num
    case "$num" in
        1)
            echo -e "${Green_font_prefix}选择了 vmess+tcp${Font_color_suffix}"
            # 在这里添加 vmess+tcp 配置代码
            ;;
        2)
            echo -e "${Green_font_prefix}选择了 vmess+ws${Font_color_suffix}"
            # 在这里添加 vmess+ws 配置代码
            ;;
        3)
            echo -e "${Green_font_prefix}选择了 vmess+tcp+tls${Font_color_suffix}"
            # 在这里添加 vmess+tcp+tls 配置代码
            ;;
        4)
            echo -e "${Green_font_prefix}选择了 vmess+ws+tls${Font_color_suffix}"
            # 在这里添加 vmess+ws+tls 配置代码
            ;;
        5)
            echo -e "${Green_font_prefix}退出设置${Font_color_suffix}"
            exit 0
            ;;
        *)
            echo -e "${Red_font_prefix}无效的选项，请重新选择${Font_color_suffix}"
            Set
            ;;
    esac
}

# 显示 V2Ray 状态
Status() {
    check_status
    echo -e "${Green_font_prefix}V2Ray 当前状态: ${status}${Font_color_suffix}"
    if [ "$status" == "running" ]; then
        echo -e "${Green_font_prefix}V2Ray 设置为开机自启${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}V2Ray 未设置为开机自启${Font_color_suffix}"
    fi
}

# 更新脚本
update_script() {
    echo -e "${Green_font_prefix}更新脚本中...${Font_color_suffix}"
    curl -s https://raw.githubusercontent.com/your-repo/your-script/main/v2ray-install.sh -o /root/V2ray/v2ray-install.sh
    chmod +x /root/V2ray/v2ray-install.sh
    echo -e "${Green_font_prefix}脚本更新完成！${Font_color_suffix}"
}

# 菜单
menu() {
    echo "=============================="
    echo -e " ${Green_font_prefix}1${Font_color_suffix}、 安装 V2Ray"
    echo -e " ${Green_font_prefix}2${Font_color_suffix}、 更新 V2Ray"
    echo -e " ${Green_font_prefix}3${Font_color_suffix}、 卸载 V2Ray"
    echo -e " ${Green_font_prefix}4${Font_color_suffix}、 启动 V2Ray"
    echo -e " ${Green_font_prefix}5${Font_color_suffix}、 停止 V2Ray"
    echo -e " ${Green_font_prefix}6${Font_color_suffix}、 重启 V2Ray"
    echo -e " ${Green_font_prefix}7${Font_color_suffix}、 查看 V2Ray 状态"
    echo -e " ${Green_font_prefix}8${Font_color_suffix}、 申请证书"
    echo -e " ${Green_font_prefix}9${Font_color_suffix}、 更新脚本"
    echo -e " ${Green_font_prefix}10${Font_color_suffix}、 退出"
    echo "=============================="
    read -p "请选择[1-10]: " num
    case "$num" in
        1)
            Install
            ;;
        2)
            Update
            ;;
        3)
            Uninstall
            ;;
        4)
            Start
            ;;
        5)
            Stop
            ;;
        6)
            Restart
            ;;
        7)
            Status
            ;;
        8)
            echo "请选择证书申请方式："
            echo -e " ${Green_font_prefix}1${Font_color_suffix}、 Cloudflare 证书"
            echo -e " ${Green_font_prefix}2${Font_color_suffix}、 自签名证书"
            read -p "请选择[1-2]: " cert_option
            case "$cert_option" in
                1)
                    request_cert
                    ;;
                2)
                    generate_self_signed_cert
                    ;;
                *)
                    echo -e "${Red_font_prefix}无效选项，请重新选择。${Font_color_suffix}"
                    ;;
            esac
            ;;
        9)
            update_script
            ;;
        10)
            exit 0
            ;;
        *)
            echo -e "${Red_font_prefix}无效选项，请重新选择。${Font_color_suffix}"
            ;;
    esac
}

menu
