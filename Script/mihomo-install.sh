#!/bin/bash

## wget -O mihomo-install.sh --no-check-certificate https://raw.githubusercontent.com/thNylHx/Tools/main/Script/mihomo-install.sh && chmod +x mihomo-install.sh && ./mihomo-install.sh

set -e -o pipefail

# 定义颜色代码
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"

# 定义脚本版本
sh_ver="1.0.9"
FILE="/root/mihomo/mihomo"
VERSION_FILE="/root/mihomo/version.txt"
SYSCTL_CONF="/etc/sysctl.conf"

clear
echo -e "================================="
echo -e " ${Green_font_prefix}欢迎使用 mihomo 一键脚本${Font_color_suffix}"
echo -e " ${Green_font_prefix}作者：${Font_color_suffix}${Red_font_prefix}thNylHx${Font_color_suffix}"
echo -e " ${Green_font_prefix}请保证科学上网已经开启${Font_color_suffix}"
echo -e " ${Green_font_prefix}安装过程中可以按 ctrl+c 强制退出${Font_color_suffix}"
echo -e "================================="

# 检查 mihomo 服务状态
check_status() {
    if pgrep -x "mihomo" > /dev/null; then
        status="running"
    else
        status="stopped"
    fi
}

# 获取当前版本
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "未安装"
    fi
}

# 显示状态
Show_Status() {
    if [ ! -f "$FILE" ]; then
        status="${Red_font_prefix}未安装${Font_color_suffix}"
    else
        check_status
        if [ "$status" == "running" ]; then
            status="${Green_font_prefix}运行中${Font_color_suffix}"
        else
            status="${Red_font_prefix}未运行${Font_color_suffix}"
        fi
    fi

    echo -e " 版本： ${Green_font_prefix}${sh_ver}${Font_color_suffix}"
    echo -e " 状态： ${status}"
}

# 检查和设置 IP 转发参数
check_ip_forward() {
    # 要检查的设置
    local IPV4_FORWARD="net.ipv4.ip_forward = 1"

    # 检查是否已存在 net.ipv4.ip_forward
    if grep -q "^${IPV4_FORWARD}$" "$SYSCTL_CONF"; then
        # 不执行 sysctl -p，因为设置已经存在
        return
    fi

    # 如果设置不存在，则添加并执行 sysctl -p
    echo "$IPV4_FORWARD" >> "$SYSCTL_CONF"
    echo -e "${Green_font_prefix}IP 转发开启成功。${Font_color_suffix}"

    # 立即生效
    sysctl -p
}

# 安装 mihomo
Install() {
    FILE="/root/mihomo/mihomo"
    
    if [ -f "$FILE" ]; then
        echo -e "${Green_font_prefix}mihomo 已经安装。${Font_color_suffix}"
        exit 0
    fi

    echo -e "${Green_font_prefix}安装 mihomo 中...${Font_color_suffix}"
    mkdir -p /root/mihomo
    cd /root/mihomo || { echo -e "${Red_font_prefix}切换到 /root/mihomo 目录失败${Font_color_suffix}"; exit 1; }

    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='amd64';;
        'x86' | 'i686' | 'i386')     ARCH='386';;
        'aarch64' | 'arm64') ARCH='arm64';;
        'armv7l')   ARCH='armv7';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
    esac
    echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"

    # 获取最新版本信息
    VERSION=$(curl -sSL "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt" || { echo -e "${Red_font_prefix}获取版本信息失败${Font_color_suffix}"; exit 1; })
    echo -e "${Green_font_prefix}获取到的最新版本: ${VERSION}${Font_color_suffix}"

    # 构造文件名
    case "$ARCH" in
        'arm64' | 'armv7' | 's390x' | '386') FILENAME="mihomo-linux-${ARCH}-${VERSION}.gz";;
        'amd64') FILENAME="mihomo-linux-${ARCH}-compatible-${VERSION}.gz";;
        *)       echo -e "${Red_font_prefix}不支持的架构: ${ARCH}${Font_color_suffix}"; exit 1;;
    esac

    echo -e "${Green_font_prefix}开始下载 ${FILENAME}${Font_color_suffix}"

    wget -t 3 -T 30 "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${FILENAME}" -O "${FILENAME}" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }

    if [ -f "$FILENAME" ]; then
        echo -e "${Green_font_prefix}${FILENAME} 下载完成, 开始部署${Font_color_suffix}"

        # 解压 
        gunzip "$FILENAME" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }

        # 根据架构重命名 mihomo 文件
        if [ -f "mihomo-linux-${ARCH}-${VERSION}" ]; then
            mv "mihomo-linux-${ARCH}-${VERSION}" mihomo
        elif [ -f "mihomo-linux-${ARCH}-compatible-${VERSION}" ]; then
            mv "mihomo-linux-${ARCH}-compatible-${VERSION}" mihomo
        else
            echo -e "${Red_font_prefix}找不到解压后的文件${Font_color_suffix}"
            exit 1
        fi
        
        # 授权
        chmod 777 mihomo
        
        # 保存版本信息
        echo "$VERSION" > /root/mihomo/version.txt
        echo -e "${Green_font_prefix}mihomo 安装成功${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}下载的文件不存在${Font_color_suffix}"
        exit 1
    fi

    # 下载 UI
    git clone https://github.com/metacubex/metacubexd.git -b gh-pages /root/mihomo/ui
    
    # 系统配置文件
    cat << EOF > /etc/systemd/system/mihomo.service
[Unit]
Description=mihomo Daemon, Another Clash Kernel.
After=network.target NetworkManager.service systemd-networkd.service iwd.service

[Service]
Type=simple
LimitNPROC=500
LimitNOFILE=1000000
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
Restart=always
ExecStartPre=/usr/bin/sleep 1s
ExecStart=/root/mihomo/mihomo -d /root/mihomo
ExecReload=/bin/kill -HUP \$MAINPID

[Install]
WantedBy=multi-user.target
EOF

    echo -e "${Green_font_prefix}mihomo 安装完成，开始配置 mihomo${Font_color_suffix}"
    Configure
}

# 更新 mihomo
Update() {
    FILE="/root/mihomo/mihomo"  # 定义 FILE 变量

    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}mihomo 未安装，无法更新${Font_color_suffix}"
        exit 1
    fi

    echo -e "${Green_font_prefix}检查更新中...${Font_color_suffix}"
    cd /root/mihomo

    # 获取当前版本
    CURRENT_VERSION=$(cat version.txt)
    # 获取最新版本
    LATEST_VERSION=$(curl -sSL "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt" || { echo -e "${Red_font_prefix}获取版本信息失败${Font_color_suffix}"; exit 1; })

    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo -e "${Green_font_prefix}当前版本: ${CURRENT_VERSION}${Font_color_suffix}"
        echo -e "${Green_font_prefix}最新版本: ${LATEST_VERSION}${Font_color_suffix}"
        echo -e "${Green_font_prefix}当前已是最新版本，无需更新！${Font_color_suffix}"
        exit 0
    fi

    echo -e "${Green_font_prefix}当前版本: ${CURRENT_VERSION}${Font_color_suffix}"
    echo -e "${Green_font_prefix}最新版本: ${LATEST_VERSION}${Font_color_suffix}"

    read -p "是否更新到最新版本？(y/n): " confirm
    case $confirm in
        [Yy]* )
            echo -e "${Green_font_prefix}开始更新 mihomo...${Font_color_suffix}"
            ARCH_RAW=$(uname -m)
            case "${ARCH_RAW}" in
                'x86_64') ARCH='amd64';;
                'x86' | 'i686' | 'i386') ARCH='386';;
                'aarch64' | 'arm64') ARCH='arm64';;
                'armv7' | 'armv7l') ARCH='armv7';;
                's390x') ARCH='s390x';;
                *) echo -e "${Red_font_prefix}不支持的架构: ${ARCH_RAW}${Font_color_suffix}"; exit 1;;
            esac

            # 构造文件名和下载链接
            case "$ARCH" in
                'arm64' | 'armv7' | 's390x' | '386') FILENAME="mihomo-linux-${ARCH}-${LATEST_VERSION}.gz";;
                'amd64') FILENAME="mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}.gz";;
                *)       FILENAME="mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}.gz";;
            esac

            echo -e "${Green_font_prefix}当前设备架构: ${ARCH_RAW}${Font_color_suffix}"

            DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${FILENAME}"

            echo -e "${Green_font_prefix}开始下载最新版本 ${FILENAME}...${Font_color_suffix}"

            wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red_font_prefix}下载失败${Font_color_suffix}"; exit 1; }

            echo -e "${Green_font_prefix}${FILENAME} 下载完成，开始更新${Font_color_suffix}"

            gunzip "$FILENAME" || { echo -e "${Red_font_prefix}解压失败${Font_color_suffix}"; exit 1; }

            # 文件移动与重命名
            if [ -f "mihomo-linux-${ARCH}-${LATEST_VERSION}" ]; then
                mv "mihomo-linux-${ARCH}-${LATEST_VERSION}" mihomo
            elif [ -f "mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}" ]; then
                mv "mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}" mihomo
            else
                echo -e "${Red_font_prefix}找不到下载后的文件${Font_color_suffix}"
                exit 1
            fi

            # 授权
            chmod 777 mihomo

            # 更新版本信息
            echo "$LATEST_VERSION" > /root/mihomo/version.txt

            # 重新加载 systemd
            systemctl daemon-reload

            # 重启 mihomo 服务
            systemctl restart mihomo

            echo -e "${Green_font_prefix}更新完成，当前版本已更新为 v${LATEST_VERSION}${Font_color_suffix}"
            ;;
        [Nn]* )
            echo -e "${Red_font_prefix}更新已取消。${Font_color_suffix}"
            ;;
        * )
            echo -e "${Red_font_prefix}无效的输入。${Font_color_suffix}"
            exit 1
            ;;
    esac
}

# 配置 mihomo
Configure() {
    echo -e "${Green_font_prefix}配置 mihomo...${Font_color_suffix}"

    # 获取用户输入机场数量
    read -p "是否有多个机场？目前只支持2个机场连接。(y/n): " multiple_airports

    if [[ "$multiple_airports" == "y" ]]; then
        # 配置多个机场
        read -p "请输入第一个机场的订阅连接: " airport_url1
        read -p "请输入第一个机场的名称: " airport_name1

        read -p "请输入第二个机场的订阅连接: " airport_url2
        read -p "请输入第二个机场的名称: " airport_name2

        cat << EOF > /root/mihomo/config.yaml
#!name = mihomo TUN 配置文件
#!desc = 说明：理论上适用于所有的 Meta 内核，已测试的有 Clash Verg Rev、Openclash、mihomo 
#!date = 2024-07-31 17:00
#!source = https://wiki.metacubex.one/example/conf/#__tabbed_1_3
#!author = thNylHx

# 这里是机场订阅更新和延迟测试相关锚点
pr: &pr {type: http, interval: 3600, health-check: {enable: true, url: https://www.gstatic.com/generate_204, interval: 300}}

# url 里填写自己的机场订阅，名称不能重复
proxy-providers:
  # 机场1
  Airport_01:
    <<: *pr
    url: "$airport_url1"
    override:
      additional-prefix: "[$airport_name1]"
  # 机场2
  Airport_02:
    <<: *pr
    url: "$airport_url2"
    override:
      additional-prefix: "[$airport_name2]"

# 全局配置
# 开启 IPv6 总开关，可选：true/false
ipv6: true
# 允许局域网连接
allow-lan: true
# HTTP(S) 和 SOCKS 代理混合端口
mixed-port: 7890
# 更换延迟计算方式,去除握手等额外延迟
unified-delay: true
# TCP 并发连接所有 IP, 将使用最快握手的 TCP
tcp-concurrent: true

# 配置 WEB UI
# UI 名字
external-ui: ui
# UI 地址
external-controller: 0.0.0.0:9090
# 自定义 UI 下载地址
external-ui-url: "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

# 匹配所有进程
find-process-mode: strict
# 全局 TLS 指纹
global-client-fingerprint: chrome

# profile 应为扩展配置，但在 mihomo, 仅作为缓存项使用
profile:
  # 储存 API 对策略组的选择，以供下次启动时使用
  store-selected: true
  # 储存 fakeip 映射表，域名再次发生连接时，使用原有映射地址
  store-fake-ip: true

# 嗅探域名 可选配置
sniffer:
  enable: true
  sniff:
    HTTP:
      ports: [80, 8080-8880]
      override-destination: true
    TLS:
      ports: [443, 8443]
    QUIC:
      ports: [443, 8443]
  skip-domain:
    - "Mijia Cloud"
    - "+.push.apple.com"

# TUN配置
tun:
  enable: true
  stack: mixed
  # 劫持所有53端口的DNS请求
  dns-hijack:
    - "any:53"
    - "tcp://any:53"
  # 指定 tun 网卡名称
  device: Network
  # 仅支持 Linux，自动设置全局路由，可以自动将全局流量路由进入 tun 网卡
  auto-route: true
  # 自动配置 iptables/nftables 以重定向 TCP 连接，需要auto-route已启用
  auto-redirect: true
  # 自动选择流量出口接口，多出口网卡同时连接的设备建议手动指定出口网卡
  auto-detect-interface: true

# DNS配置
dns:
  # 关闭将使用系统 DNS
  enable: true
  # DNS
  ipv6: true
  # 遵循规则
  respect-rules: true
  # 模式：redir-host 或 fake-ip
  enhanced-mode: fake-ip
  # fake ip 白名单列表'以下地址不会下发fakeip映射用于连接
  fake-ip-filter:
    - "*"
    - "+.lan"
    - "+.local"
    - "+.market.xiaomi.com"
   # 使用的DNS服务器
  nameserver:
    - https://120.53.53.53/dns-query
    - https://223.5.5.5/dns-query
  # 代理服务器使用的DNS服务器
  proxy-server-nameserver:
    - https://dns.google/dns-query
    - https://dns.cloudflare.com/dns-query

# 单个出站代理节点
proxies: 
  - name: "国内直连"
    type: direct
    udp: true
    
# 策略组相关
pg: &pg {type: select, proxies: [手动选择, 自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
# 手动选择策略
mt: &mt {type: select, include-all-providers: true}
# 自动优选策略
at: &at {type: url-test, include-all-providers: true, url: https://www.gstatic.com/generate_204, tolerance: 10, interval: 300}
# 负载均衡策略
lb: &lb {type: load-balance, include-all: true, interval: 300, url: https://www.gstatic.com/generate_204}

# 策略组
proxy-groups:
  # 策略分组
  - {name: 手动选择, type: select, proxies: [自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
  - {name: YouTube, <<: *pg}
  - {name: Google, <<: *pg}
  - {name: Microsoft, <<: *pg}
  - {name: TikTok, <<: *pg}
  - {name: Netflix, <<: *pg}
  - {name: DisneyPlus, <<: *pg}
  - {name: Spotify, <<: *pg}
  - {name: Telegram, <<: *pg}
  - {name: ChatGPT, <<: *pg}
  - {name: PayPal, <<: *pg}
  - {name: Twitter, <<: *pg}
  - {name: Facebook, <<: *pg}
  - {name: GlobalGFW, <<: *pg}
  - {name: Apple, type: select, proxies: [国内直连, 手动选择, 自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
  - {name: Bilibili, type: select, proxies: [国内直连, 手动选择, 自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
  - {name: China, type: select, proxies: [国内直连, 手动选择, 自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
  - {name: 兜底规则, <<: *pg}
  # 地区分组
  - {name: 香港节点, <<: *at, filter: "(?=.*(港|HK|(?i)Hong))^((?!(台|日|韩|新|深|美)).)*$"}
  - {name: 台湾节点, <<: *at, filter: "(?=.*(台|TW|(?i)Taiwan))^((?!(港|日|韩|新|美)).)*$" }
  - {name: 美国节点, <<: *at, filter: "(?=.*(美|US|(?i)States|America))^((?!(港|台|日|韩|新)).)*$"}
  - {name: 狮城节点, <<: *at, filter: "(?=.*(新|狮|獅|SG|(?i)Singapore))^((?!(港|台|日|韩|美|西)).)*$"}
  - {name: 日本节点, <<: *at, filter: "(?=.*(日|JP|(?i)Japan))^((?!(港|台|韩|新|美)).)*$" }
  - {name: 韩国节点, <<: *at, filter: "(?=.*(韩|KR|(?i)Korea))^((?!(台|日|港|新|美)).)*$"}
  - {name: 自动选择, <<: *at}

# 分流策略
rules:
  - RULE-SET,Lan,China
  - RULE-SET,Adrules,REJECT
  - RULE-SET,YouTube,YouTube
  - RULE-SET,Google,Google
  - RULE-SET,GitHub,Microsoft
  - RULE-SET,OneDrive,Microsoft
  - RULE-SET,Microsoft,Microsoft
  - RULE-SET,TikTok,TikTok
  - RULE-SET,Netflix,Netflix
  - RULE-SET,DisneyPlus,DisneyPlus
  - RULE-SET,Spotify,Spotify
  - RULE-SET,Telegram,Telegram
  - RULE-SET,OpenAI,ChatGPT
  - RULE-SET,PayPal,PayPal
  - RULE-SET,Twitter,Twitter
  - RULE-SET,Facebook,Facebook
  - RULE-SET,GlobalMedia,GlobalGFW
  - RULE-SET,GlobalGFW,GlobalGFW
  - RULE-SET,Apple,Apple
  - RULE-SET,Bilibili,Bilibili
  - RULE-SET,WeChat,China
  - RULE-SET,ChinaMedia,China
  - RULE-SET,China,China
  - GEOIP,CN,China
  - MATCH,兜底规则

# 规则集锚点
rule-anchor:
  # classical 规则相关
  classical: &classical {type: http, interval: 43200, behavior: classical, format: text}

# 订阅规则集
rule-providers:
  # 广告拦截
  Adrules:
    <<: *classical
    url: "https://adrules.top/adrules.list"
  # 谷歌服务
  YouTube:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/YouTube.list"
  Google:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Google.list"
  # 微软服务
  GitHub:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/GitHub.list"
  OneDrive:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/OneDrive.list"
  Microsoft:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Microsoft.list"
  # 电报服务
  Telegram:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Telegram.list"
  # ChatGPT
  OpenAI:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/OpenAI.list"
  # 贝宝支付
  PayPal:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/PayPal.list"
  # 推特加速
  Twitter:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Twitter.list"
  # 脸书加速
  Facebook:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Facebook.list"
  # 海外抖音
  TikTok:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/TikTok.list"
  # 奈飞影视
  Netflix:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Netflix.list"
  # 迪士尼+
  DisneyPlus:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/DisneyPlus.list"
  # Spotify
  Spotify:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Spotify.list"
  # 海外媒体
  GlobalMedia:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/GlobalMedia.list"
  # 海外服务
  GlobalGFW:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Global.list"
  # 苹果服务
  Apple:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Apple.list"
  # 哔哩哔哩
  Bilibili:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Bilibili.list"
  # 国内服务
  WeChat:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/WeChat.list"
  ChinaMedia:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/ChinaMedia.list"
  China:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/China.list"
  # 本地/局域网
  Lan:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Local.list"
EOF

    else
        # 配置单个机场
        read -p "请输入机场的订阅连接: " airport_url
        read -p "请输入机场的名称: " airport_name

        cat << EOF > /root/mihomo/config.yaml
#!name = mihomo TUN 配置文件
#!desc = 说明：理论上适用于所有的 Meta 内核，已测试的有 Clash Verg Rev、Openclash、mihomo 
#!date = 2024-07-31 17:00
#!source = https://wiki.metacubex.one/example/conf/#__tabbed_1_3
#!author = thNylHx

# 这里是机场订阅更新和延迟测试相关锚点
pr: &pr {type: http, interval: 3600, health-check: {enable: true, url: https://www.gstatic.com/generate_204, interval: 300}}

# url 里填写自己的机场订阅，名称不能重复
proxy-providers:
  # 单个机场
  Airport_01:
    <<: *pr
    url: "$airport_url"
    override:
      additional-prefix: "[$airport_name]"

# 全局配置
# 开启 IPv6 总开关，可选：true/false
ipv6: true
# 允许局域网连接
allow-lan: true
# HTTP(S) 和 SOCKS 代理混合端口
mixed-port: 7890
# 更换延迟计算方式,去除握手等额外延迟
unified-delay: true
# TCP 并发连接所有 IP, 将使用最快握手的 TCP
tcp-concurrent: true

# 配置 WEB UI
# UI 名字
external-ui: ui
# UI 地址
external-controller: 0.0.0.0:9090
# 自定义 UI 下载地址
external-ui-url: "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

# 匹配所有进程
find-process-mode: strict
# 全局 TLS 指纹
global-client-fingerprint: chrome

# profile 应为扩展配置，但在 mihomo, 仅作为缓存项使用
profile:
  # 储存 API 对策略组的选择，以供下次启动时使用
  store-selected: true
  # 储存 fakeip 映射表，域名再次发生连接时，使用原有映射地址
  store-fake-ip: true

# 嗅探域名 可选配置
sniffer:
  enable: true
  sniff:
    HTTP:
      ports: [80, 8080-8880]
      override-destination: true
    TLS:
      ports: [443, 8443]
    QUIC:
      ports: [443, 8443]
  skip-domain:
    - "Mijia Cloud"
    - "+.push.apple.com"

# TUN配置
tun:
  enable: true
  stack: mixed
  # 劫持所有53端口的DNS请求
  dns-hijack:
    - "any:53"
    - "tcp://any:53"
  # 指定 tun 网卡名称
  device: Network
  # 仅支持 Linux，自动设置全局路由，可以自动将全局流量路由进入 tun 网卡
  auto-route: true
  # 自动配置 iptables/nftables 以重定向 TCP 连接，需要auto-route已启用
  auto-redirect: true
  # 自动选择流量出口接口，多出口网卡同时连接的设备建议手动指定出口网卡
  auto-detect-interface: true

# DNS配置
dns:
  # 关闭将使用系统 DNS
  enable: true
  # DNS
  ipv6: true
  # 遵循规则
  respect-rules: true
  # 模式：redir-host 或 fake-ip
  enhanced-mode: fake-ip
  # fake ip 白名单列表'以下地址不会下发fakeip映射用于连接
  fake-ip-filter:
    - "*"
    - "+.lan"
    - "+.local"
    - "+.market.xiaomi.com"
   # 使用的DNS服务器
  nameserver:
    - https://120.53.53.53/dns-query
    - https://223.5.5.5/dns-query
  # 代理服务器使用的DNS服务器
  proxy-server-nameserver:
    - https://dns.google/dns-query
    - https://dns.cloudflare.com/dns-query

# 单个出站代理节点
proxies: 
  - name: "国内直连"
    type: direct
    udp: true
    
# 策略组相关
pg: &pg {type: select, proxies: [手动选择, 自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
# 手动选择策略
mt: &mt {type: select, include-all-providers: true}
# 自动优选策略
at: &at {type: url-test, include-all-providers: true, url: https://www.gstatic.com/generate_204, tolerance: 10, interval: 300}
# 负载均衡策略
lb: &lb {type: load-balance, include-all: true, interval: 300, url: https://www.gstatic.com/generate_204}

# 策略组
proxy-groups:
  # 策略分组
  - {name: 手动选择, type: select, proxies: [自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
  - {name: YouTube, <<: *pg}
  - {name: Google, <<: *pg}
  - {name: Microsoft, <<: *pg}
  - {name: TikTok, <<: *pg}
  - {name: Netflix, <<: *pg}
  - {name: DisneyPlus, <<: *pg}
  - {name: Spotify, <<: *pg}
  - {name: Telegram, <<: *pg}
  - {name: ChatGPT, <<: *pg}
  - {name: PayPal, <<: *pg}
  - {name: Twitter, <<: *pg}
  - {name: Facebook, <<: *pg}
  - {name: GlobalGFW, <<: *pg}
  - {name: Apple, type: select, proxies: [国内直连, 手动选择, 自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
  - {name: Bilibili, type: select, proxies: [国内直连, 手动选择, 自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
  - {name: China, type: select, proxies: [国内直连, 手动选择, 自动选择, 香港节点, 台湾节点, 美国节点, 狮城节点, 日本节点, 韩国节点]}
  - {name: 兜底规则, <<: *pg}
  # 地区分组
  - {name: 香港节点, <<: *at, filter: "(?=.*(港|HK|(?i)Hong))^((?!(台|日|韩|新|深|美)).)*$"}
  - {name: 台湾节点, <<: *at, filter: "(?=.*(台|TW|(?i)Taiwan))^((?!(港|日|韩|新|美)).)*$" }
  - {name: 美国节点, <<: *at, filter: "(?=.*(美|US|(?i)States|America))^((?!(港|台|日|韩|新)).)*$"}
  - {name: 狮城节点, <<: *at, filter: "(?=.*(新|狮|獅|SG|(?i)Singapore))^((?!(港|台|日|韩|美|西)).)*$"}
  - {name: 日本节点, <<: *at, filter: "(?=.*(日|JP|(?i)Japan))^((?!(港|台|韩|新|美)).)*$" }
  - {name: 韩国节点, <<: *at, filter: "(?=.*(韩|KR|(?i)Korea))^((?!(台|日|港|新|美)).)*$"}
  - {name: 自动选择, <<: *at}

# 分流策略
rules:
  - RULE-SET,Lan,China
  - RULE-SET,Adrules,REJECT
  - RULE-SET,YouTube,YouTube
  - RULE-SET,Google,Google
  - RULE-SET,GitHub,Microsoft
  - RULE-SET,OneDrive,Microsoft
  - RULE-SET,Microsoft,Microsoft
  - RULE-SET,TikTok,TikTok
  - RULE-SET,Netflix,Netflix
  - RULE-SET,DisneyPlus,DisneyPlus
  - RULE-SET,Spotify,Spotify
  - RULE-SET,Telegram,Telegram
  - RULE-SET,OpenAI,ChatGPT
  - RULE-SET,PayPal,PayPal
  - RULE-SET,Twitter,Twitter
  - RULE-SET,Facebook,Facebook
  - RULE-SET,GlobalMedia,GlobalGFW
  - RULE-SET,GlobalGFW,GlobalGFW
  - RULE-SET,Apple,Apple
  - RULE-SET,Bilibili,Bilibili
  - RULE-SET,WeChat,China
  - RULE-SET,ChinaMedia,China
  - RULE-SET,China,China
  - GEOIP,CN,China
  - MATCH,兜底规则

# 规则集锚点
rule-anchor:
  # classical 规则相关
  classical: &classical {type: http, interval: 43200, behavior: classical, format: text}

# 订阅规则集
rule-providers:
  # 广告拦截
  Adrules:
    <<: *classical
    url: "https://adrules.top/adrules.list"
  # 谷歌服务
  YouTube:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/YouTube.list"
  Google:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Google.list"
  # 微软服务
  GitHub:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/GitHub.list"
  OneDrive:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/OneDrive.list"
  Microsoft:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Microsoft.list"
  # 电报服务
  Telegram:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Telegram.list"
  # ChatGPT
  OpenAI:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/OpenAI.list"
  # 贝宝支付
  PayPal:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/PayPal.list"
  # 推特加速
  Twitter:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Twitter.list"
  # 脸书加速
  Facebook:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Facebook.list"
  # 海外抖音
  TikTok:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/TikTok.list"
  # 奈飞影视
  Netflix:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Netflix.list"
  # 迪士尼+
  DisneyPlus:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/DisneyPlus.list"
  # Spotify
  Spotify:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Spotify.list"
  # 海外媒体
  GlobalMedia:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/GlobalMedia.list"
  # 海外服务
  GlobalGFW:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Global.list"
  # 苹果服务
  Apple:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Apple.list"
  # 哔哩哔哩
  Bilibili:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/Bilibili.list"
  # 国内服务
  WeChat:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/WeChat.list"
  ChinaMedia:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Media/ChinaMedia.list"
  China:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/China.list"
  # 本地/局域网
  Lan:
    <<: *classical
    url: "https://raw.githubusercontent.com/thNylHx/Tools/main/Ruleset/Other/Local.list"
EOF

    fi

    echo -e "${Green_font_prefix}mihomo 配置完成，正在启动中...${Font_color_suffix}"
    systemctl daemon-reload
    systemctl enable mihomo
    systemctl start mihomo
    systemctl status mihomo

    # 检查服务状态
    check_status

    # 显示服务状态
    if [ "$status" == "running" ]; then
        echo -e "${Green_font_prefix}当前状态：运行中${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}当前状态：未运行${Font_color_suffix}"
    fi
}

# 修改 mihomo 配置
Modify_Configuration() {
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}mihomo 未安装，无法修改配置${Font_color_suffix}"
        exit 1
    fi

    echo -e "${Green_font_prefix} mihomo 配置修改${Font_color_suffix}"
    Configure
}

# 启动 mihomo
Start() {
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}mihomo 未安装，无法启动${Font_color_suffix}"
        exit 1
    fi

    if systemctl is-active --quiet mihomo; then
        echo -e "${Green_font_prefix}mihomo 已经在运行中${Font_color_suffix}"
        exit 0
    fi

    echo -e "${Green_font_prefix}mihomo 启动中${Font_color_suffix}"
    
    # 尝试启用并启动服务
    if systemctl enable mihomo && systemctl start mihomo; then
        echo -e "${Green_font_prefix}mihomo 启动成功${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}mihomo 启动失败${Font_color_suffix}"
        exit 1
    fi

    # 检查并显示服务状态
    if systemctl is-active --quiet mihomo; then
        echo -e "${Green_font_prefix}当前状态：运行中${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}当前状态：未运行${Font_color_suffix}"
        exit 1
    fi
}

# 停止 mihomo
Stop() {
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}mihomo 未安装，无法停止${Font_color_suffix}"
        exit 1
    fi

    if ! systemctl is-active --quiet mihomo; then
        echo -e "${Green_font_prefix}mihomo 已经停止${Font_color_suffix}"
        exit 0
    fi

    echo -e "${Green_font_prefix}mihomo 停止中${Font_color_suffix}"
    
    # 尝试停止服务
    if systemctl stop mihomo; then
        echo -e "${Green_font_prefix}mihomo 成功停止${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}mihomo 停止失败${Font_color_suffix}"
        exit 1
    fi
    
    # 检查并显示服务状态
    if systemctl is-active --quiet mihomo; then
        echo -e "${Green_font_prefix}当前状态：运行中${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}当前状态：未运行${Font_color_suffix}"
        exit 1
    fi
    
}

# 卸载 mihomo
Uninstall() {
    # 检查服务文件是否存在以判断是否安装
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}mihomo 未安装，无法卸载${Font_color_suffix}"
        exit 1
    fi

    echo -e "${Green_font_prefix}mihomo 开始卸载${Font_color_suffix}"

    # 停止并禁用服务，如果失败则忽略错误
    systemctl stop mihomo || true
    systemctl disable mihomo || true

    # 删除服务文件和安装目录
    rm -f "$FILE"
    rm -f /etc/systemd/system/mihomo.service
    rm -rf /root/mihomo

    # 重新加载 systemd 守护程序
    systemctl daemon-reload

    # 检查卸载是否成功
    if [ ! -f "$FILE" ] && [ ! -d "/root/mihomo" ]; then
        echo -e "${Green_font_prefix}mihomo 卸载完成${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}卸载过程中出现问题，请手动检查${Font_color_suffix}"
    fi
    
    # 删除文件和目录
    if rm -f "$FILE" && rm -rf "$INSTALL_DIR"; then
        echo -e "${Green_font_prefix}mihomo 成功卸载${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}mihomo 卸载过程中发生错误${Font_color_suffix}"
        exit 1
    fi
}

# 重启 mihomo
Restart() {
    # 检查是否已安装 mihomo
    if [ ! -f "$FILE" ]; then
        echo -e "${Red_font_prefix}mihomo 未安装，无法重启${Font_color_suffix}"
        exit 1
    fi

    echo -e "${Green_font_prefix}mihomo 准备重启${Font_color_suffix}"
    
    # 重启服务
    if systemctl restart mihomo; then
        echo -e "${Green_font_prefix}mihomo 重启中${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}mihomo 重启失败${Font_color_suffix}"
        exit 1
    fi
    
    echo -e "${Green_font_prefix}mihomo 重启完成${Font_color_suffix}"

    # 检查并显示服务状态
    if systemctl is-active --quiet mihomo; then
        echo -e "${Green_font_prefix}当前状态：运行中${Font_color_suffix}"
    else
        echo -e "${Red_font_prefix}当前状态：未运行${Font_color_suffix}"
        exit 1
    fi
}

# 主菜单
# 函数定义在这里
Main() {
    Show_Status
    echo -e "================================="
    echo -e " ${Green_font_prefix}1${Font_color_suffix}、 安装 mihomo"
    echo -e " ${Green_font_prefix}2${Font_color_suffix}、 更新 mihomo"
    echo -e " ${Green_font_prefix}3${Font_color_suffix}、 配置 mihomo"
    echo -e " ${Green_font_prefix}4${Font_color_suffix}、 卸载 mihomo"
    echo -e " ${Green_font_prefix}5${Font_color_suffix}、 启动 mihomo"
    echo -e " ${Green_font_prefix}6${Font_color_suffix}、 停止 mihomo"
    echo -e " ${Green_font_prefix}7${Font_color_suffix}、 重启 mihomo"
    echo -e " ${Green_font_prefix}0${Font_color_suffix}、 退出脚本"
    echo -e "================================="
    read -p "请输入选项[0-7]: " num

    case "$num" in

        1) check_ip_forward; Install ;;
        2) Update ;;
        3) Modify_Configuration ;;
        4) Uninstall ;;
        5) Start ;;
        6) Stop ;;
        7) Restart ;;
        0) exit 0 ;;
        *) echo -e "${Red_font_prefix}无效选项，请重新选择${Font_color_suffix}" ;;
    esac
}

# 调用主菜单函数
Main
