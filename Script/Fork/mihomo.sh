# 2024-10-31 18:40

#!/bin/bash

# 创建规则目录
mkdir -p Tools/Ruleset/mihomo/{geoip,geosite}

#--- mihomo ---#
# geosite
# ADS
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Ads_all.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-ads-all.mrs"
# 本地/局域网
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Local.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/private.mrs"
# 国内直连
curl -L -o Tools-repo/Ruleset/mihomo/geosite/China.mrs  "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.mrs"
# AI
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Openai.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/openai.mrs"
# PayPal
curl -L -o Tools-repo/Ruleset/mihomo/geosite/PayPal.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/paypal.mrs"
# 苹果
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Apple.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/apple.mrs"
# 海外代理
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Global.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/geolocation-!cn.mrs"
# 谷歌平台
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Google.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/YouTube.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.mrs"
# 游戏平台
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Steam.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/steam.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Epic.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/epicgames.mrs"
# 社交平台
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Facebook.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/facebook.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Instagram.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/instagram.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Twitter.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Telegram.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/telegram.mrs"
# 微软平台
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Line.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/line.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/GitHub.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/OneDrive.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/onedrive.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Microsoft.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/microsoft.mrs"
# 影视媒体
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Tiktok.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/tiktok.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Bilibili.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/bilibili.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Disney.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/disney.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Netflix.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Spotify.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/spotify.mrs"


# geoip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Local.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/China.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Netflix.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Twitter.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Telegram.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/telegram.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Facebook.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Google.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.mrs"
