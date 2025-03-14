#!/bin/bash

# 2025-03-14 17:00

# 创建规则目录
mkdir -p Tools/Ruleset/mihomo/{geoip,geosite}

# 定义下载函数
download_file() {
  local output_path="$1"
  local url="$2"
  curl -L -o "$output_path" "$url"
}

#--- mihomo mrs ---#

# geosite 文件列表，格式：文件名|下载地址
geosite_downloads=(
  "Ads_all.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-ads-all.mrs"
  "Local.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/private.mrs"
  "China.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.mrs"
  "Openai.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/openai.mrs"
  "PayPal.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/paypal.mrs"
  "Apple.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/apple.mrs"
  "Global.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/geolocation-!cn.mrs"
  "Google.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.mrs"
  "YouTube.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.mrs"
  "Steam.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/steam.mrs"
  "Epic.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/epicgames.mrs"
  "Facebook.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/facebook.mrs"
  "Instagram.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/instagram.mrs"
  "Twitter.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.mrs"
  "telegram.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/telegram.mrs"
  "Line.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/line.mrs"
  "GitHub.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.mrs"
  "OneDrive.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/onedrive.mrs"
  "Microsoft.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/microsoft.mrs"
  "tiktok.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/tiktok.mrs"
  "Bilibili.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/bilibili.mrs"
  "Disney.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/disney.mrs"
  "Netflix.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.mrs"
  "Spotify.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/spotify.mrs"
)

# 循环下载 geosite 文件
for item in "${geosite_downloads[@]}"; do
  filename="${item%%|*}"
  url="${item#*|}"
  download_file "Tools-repo/Ruleset/mihomo/geosite/${filename}" "$url"
done

# geoip 文件列表，格式：文件名|下载地址
geoip_downloads=(
  "Local.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.mrs"
  "China.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.mrs"
  "Netflix.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.mrs"
  "Twitter.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.mrs"
  "telegram.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/telegram.mrs"
  "Facebook.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.mrs"
  "Google.mrs|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.mrs"
)

# 循环下载 geoip 文件
for item in "${geoip_downloads[@]}"; do
  filename="${item%%|*}"
  url="${item#*|}"
  download_file "Tools-repo/Ruleset/mihomo/geoip/${filename}" "$url"
done