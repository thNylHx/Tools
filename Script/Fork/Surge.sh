# 2024-10-31 19:25

#!/bin/bash

# 创建规则目录
mkdir -p Tools/Ruleset/Surge/{Block,Media,Other}

#--- surge ---#
# 广告拦截
# MetaCubeX
curl -L -o Tools-repo/Ruleset/Surge/Block/Ads_category-ads-all.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/classical/category-ads-all.list"
# ACL4SSR
curl -L -o Tools-repo/Ruleset/Surge/Block/Ads_BanAD.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanAD.list"
curl -L -o Tools-repo/Ruleset/Surge/Block/Ads_BanProgramAD.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanProgramAD.list"
# limbopro
curl -L -o Tools-repo/Ruleset/Surge/Block/Ads_Adblock4limbo_surge.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/Surge/rule/Adblock4limbo_surge.list"
curl -L -o Tools-repo/Ruleset/Surge/Block/Ads_easyprivacy_surge.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easyprivacy_surge.list"
curl -L -o Tools-repo/Ruleset/Surge/Block/Ads_easylist_surge.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easylist_surge.list"
# ConnersHua
curl -L -o Tools-repo/Ruleset/Surge/Block/Ads_Advertising.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Advertising.list"
curl -L -o Tools-repo/Ruleset/Surge/Block/Ads_Malicious.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Malicious.list"
curl -L -o Tools-repo/Ruleset/Surge/Block/Ads_Tracking.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Tracking.list"

# 本地/局域网
curl -L -o Tools-repo/Ruleset/Surge/Other/Private_ip.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.list"

# PayPal
curl -L -o Tools-repo/Ruleset/Surge/Other/PayPal.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/paypal.list"

# AI
curl -L -o Tools-repo/Ruleset/Surge/Other/Openai.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/classical/openai.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/OpenAI.list "https://kelee.one/Tool/Loon/Rule/AI.list"

# 游戏平台
curl -L -o Tools-repo/Ruleset/Surge/Other/Steam.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/steam.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/Epic.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/epicgames.list"

# 谷歌平台
curl -L -o Tools-repo/Ruleset/Surge/Media/YouTube.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/youtube.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/YouTubeMusic.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTubeMusic.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/Google.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/google.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/Google_ip.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.list"

# 微软平台
curl -L -o Tools-repo/Ruleset/Surge/Other/Line.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/line.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/GitHub.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/github.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/OneDrive.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/onedrive.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/Microsoft.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/microsoft.list"

# 社交平台
curl -L -o Tools-repo/Ruleset/Surge/Media/Telegram.list "https://raw.githubusercontent.com/Repcz/Tool/X/Surge/Rules/Telegram.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/twitter.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Twitter_ip.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Facebook.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/facebook.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Facebook_ip.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Instagram.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/instagram.list"

# 影视媒体
# curl -L -o Tools-repo/Ruleset/Surge/Media/TikTok.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/classical/tiktok.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/TikTok.list "https://kelee.one/Tool/Loon/Rule/TikTok.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/GlobalMedia.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyMedia.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/BilibiliHMT.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/BilibiliHMT.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/ChinaMedia.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ChinaMedia.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Bilibili.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/bilibili.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Disney.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/disney.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Netflix.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/netflix.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Netflix_ip.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.list"
curl -L -o Tools-repo/Ruleset/Surge/Media/Spotify.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/spotify.list"

# 海外代理
curl -L -o Tools-repo/Ruleset/Surge/Other/GlobalGFW.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyGFWlist.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/Global.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/geolocation-!cn.list"

# 苹果
# curl -L -o Tools-repo/Ruleset/Surge/Other/Apple.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/apple.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/Apple.list "https://github.com/ACL4SSR/ACL4SSR/raw/master/Clash/Apple.list"

# 国内直连
curl -L -o Tools-repo/Ruleset/Surge/Other/China.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/cn.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/China_ip.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"
curl -L -o Tools-repo/Ruleset/Surge/Other/ChinaASN.list "https://raw.githubusercontent.com/missuo/ASN-China/main/ASN.China.list"
