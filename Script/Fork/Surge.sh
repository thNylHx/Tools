#!/bin/bash

# 2025-03-14 17:00

# 创建规则目录
mkdir -p Tools/Ruleset/Surge/{Block,Media,Other}

# 定义下载函数
download_file() {
  local dest="$1"
  local url="$2"
  curl -L -o "$dest" "$url"
}

# --- Block 类（广告拦截） ---
block_downloads=(
  "Ads_all.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/classical/category-ads-all.list"
  "Ads_BanAD.list|https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanAD.list"
  "Ads_BanProgramAD.list|https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanProgramAD.list"
  "Ads_Adblock4limbo_surge.list|https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/Surge/rule/Adblock4limbo_surge.list"
  "Ads_easyprivacy_surge.list|https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easyprivacy_surge.list"
  "Ads_easylist_surge.list|https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easylist_surge.list"
  "Ads_Advertising.list|https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Advertising.list"
  "Ads_Malicious.list|https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Malicious.list"
  "Ads_Tracking.list|https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Tracking.list"
)

for item in "${block_downloads[@]}"; do
  filename="${item%%|*}"
  url="${item#*|}"
  download_file "Tools/Ruleset/Surge/Block/${filename}" "$url"
done

# --- Other 类（本地/局域网、PayPal、AI、游戏平台、谷歌平台、微软平台、海外代理、苹果、国内直连） ---
other_downloads=(
  "Private_ip.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.list"
  "PayPal.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/paypal.list"
  "Openai.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/classical/openai.list"
  "Steam.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/steam.list"
  "Epic.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/epicgames.list"
  "Google.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/google.list"
  "Google_ip.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.list"
  "Line.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/line.list"
  "GitHub.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/github.list"
  "OneDrive.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/onedrive.list"
  "Microsoft.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/microsoft.list"
  "GlobalGFW.list|https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyGFWlist.list"
  "Global.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/geolocation-!cn.list"
  "Apple.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/apple.list"
  "AppleCN.list|https://github.com/ACL4SSR/ACL4SSR/raw/master/Clash/Apple.list"
  "China.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/cn.list"
  "China_ip.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"
  "ChinaASN.list|https://raw.githubusercontent.com/missuo/ASN-China/main/ASN.China.list"
)

for item in "${other_downloads[@]}"; do
  filename="${item%%|*}"
  url="${item#*|}"
  download_file "Tools/Ruleset/Surge/Other/${filename}" "$url"
done

# --- Media 类（谷歌平台、社交平台、影视媒体） ---
media_downloads=(
  "YouTube.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/youtube.list"
  "YouTubeMusic.list|https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTubeMusic.list"
  "Telegram.list|https://raw.githubusercontent.com/Repcz/Tool/X/Surge/Rules/Telegram.list"
  "Twitter.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/twitter.list"
  "Twitter_ip.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.list"
  "Facebook.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/facebook.list"
  "Facebook_ip.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.list"
  "Instagram.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/instagram.list"
  "TikTok.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/classical/tiktok.list"
  "GlobalMedia.list|https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyMedia.list"
  "BilibiliHMT.list|https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/BilibiliHMT.list"
  "ChinaMedia.list|https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ChinaMedia.list"
  "Bilibili.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/bilibili.list"
  "Disney.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/disney.list"
  "Netflix.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/netflix.list"
  "Netflix_ip.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.list"
  "Spotify.list|https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/spotify.list"
)

for item in "${media_downloads[@]}"; do
  filename="${item%%|*}"
  url="${item#*|}"
  download_file "Tools/Ruleset/Surge/Media/${filename}" "$url"
done