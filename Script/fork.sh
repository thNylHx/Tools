# 2024-06-28 17:30

#!/bin/bash

# 创建规则目录
mkdir -p Tools/Ruleset/{Block,ClashMeta,Media,Other}

#--- Surge ---#
# 广告拦截
# RuCu6
curl -L -o Tools-repo/Ruleset/Block/BlockAds.list "https://raw.githubusercontent.com/RuCu6/QuanX/main/Rules/MyBlockAds.list"
# ACL4SSR
curl -L -o Tools-repo/Ruleset/Block/BlockAdg.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanAD.list"
# limbopro
curl -L -o Tools-repo/Ruleset/Block/BlockAdb.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/Surge/rule/Adblock4limbo_surge.list"
curl -L -o Tools-repo/Ruleset/Block/BlockPrivacy.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easyprivacy_surge.list"
curl -L -o Tools-repo/Ruleset/Block/BlockEasyListChina.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easylistchina_surge.list"
# ConnersHua
curl -L -o Tools-repo/Ruleset/Block/BlockAdvertising.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Advertising.list"
curl -L -o Tools-repo/Ruleset/Block/BlockHijacking.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Hijacking.list"
curl -L -o Tools-repo/Ruleset/Block/BlockTracking.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Tracking.list"

# 影视媒体
curl -L -o Tools-repo/Ruleset/Media/Bilibili.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/bilibili.list"
curl -L -o Tools-repo/Ruleset/Media/BilibiliHMT.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/BilibiliHMT.list"
curl -L -o Tools-repo/Ruleset/Media/ChinaMedia.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ChinaMedia.list"
curl -L -o Tools-repo/Ruleset/Media/Disney.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/disney.list"
curl -L -o Tools-repo/Ruleset/Media/GlobalMedia.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyMedia.list"
curl -L -o Tools-repo/Ruleset/Media/Netflix.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/netflix.list"
curl -L -o Tools-repo/Ruleset/Media/NetflixIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/classical/netflix.list"
curl -L -o Tools-repo/Ruleset/Media/Spotify.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/spotify.list"
curl -L -o Tools-repo/Ruleset/Media/TikTok.list "https://gitlab.com/lodepuly/vpn_tool/-/raw/master/Tool/Loon/Rule/TikTok.list"

# 社交平台
curl -L -o Tools-repo/Ruleset/Media/Telegram.list "https://raw.githubusercontent.com/Repcz/Tool/X/Surge/Rules/Telegram.list"
curl -L -o Tools-repo/Ruleset/Media/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/twitter.list"
curl -L -o Tools-repo/Ruleset/Media/TwitterIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/classical/twitter.list"
curl -L -o Tools-repo/Ruleset/Media/Facebook.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/facebook.list"
curl -L -o Tools-repo/Ruleset/Media/FacebookIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/classical/facebook.list"
curl -L -o Tools-repo/Ruleset/Media/Instagram.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/instagram.list"

# 谷歌平台
curl -L -o Tools-repo/Ruleset/Media/YouTube.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTube.list"
curl -L -o Tools-repo/Ruleset/Media/YouTubeMusic.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTubeMusic.list"
curl -L -o Tools-repo/Ruleset/Other/Google.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/google.list"
curl -L -o Tools-repo/Ruleset/Other/GoogleIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/classical/google.list"

# PayPal
curl -L -o Tools-repo/Ruleset/Media/PayPal.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/paypal.list"

# OpenAI
curl -L -o Tools-repo/Ruleset/Other/AI.list "https://gitlab.com/lodepuly/vpn_tool/-/raw/master/Tool/Loon/Rule/AI.list"

# 微软平台
curl -L -o Tools-repo/Ruleset/Other/GitHub.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/github.list"
curl -L -o Tools-repo/Ruleset/Other/OneDrive.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/onedrive.list"
curl -L -o Tools-repo/Ruleset/Other/Microsoft.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/microsoft.list"

# 海外代理
curl -L -o Tools-repo/Ruleset/Other/GlobalGFW.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyGFWlist.list"

# 国内直连
curl -L -o Tools-repo/Ruleset/Other/China.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/cn.list"
curl -L -o Tools-repo/Ruleset/Other/ChinaIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/classical/cn.list"

#--- ClashMeta ---#
# PayPal
curl -L -o Tools-repo/Ruleset/ClashMeta/PayPal.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/paypal.list"

# 影视媒体
curl -L -o Tools-repo/Ruleset/ClashMeta/Bilibili.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/bilibili.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Disney.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/disney.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Netflix.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/NetflixIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.list"

# 社交平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Facebook.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/facebook.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/FacebookIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Instagram.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/instagram.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/TwitterIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.list"

# 谷歌平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Google.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/GoogleIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/YouTube.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.list"

# 微软平台
curl -L -o Tools-repo/Ruleset/ClashMeta/GitHub.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.list"
curl -L -o Tools-repo/Ruleset/Other/OneDrive.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/onedrive.list"
curl -L -o Tools-repo/Ruleset/Other/Microsoft.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/microsoft.list"

# 国内直连
curl -L -o Tools-repo/Ruleset/ClashMeta/China.list  "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/ChinaIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"
