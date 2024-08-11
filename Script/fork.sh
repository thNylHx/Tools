# 2024-08-11 20:00

#!/bin/bash

# 创建规则目录
mkdir -p Tools/Ruleset/{Block,ClashMeta,Media,Other}

#--- Surge ---#
# 广告拦截
# RuCu6
curl -L -o Tools-repo/Ruleset/Block/BlockAdRuCu6.list "https://raw.githubusercontent.com/RuCu6/QuanX/main/Rules/MyBlockAds.list"
# ACL4SSR
curl -L -o Tools-repo/Ruleset/Block/BlockAdACL4SSR.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanAD.list"
# limbopro
curl -L -o Tools-repo/Ruleset/Block/BlockAdlimbopro.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/Surge/rule/Adblock4limbo_surge.list"
curl -L -o Tools-repo/Ruleset/Block/BlockPrivacy.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easyprivacy_surge.list"
curl -L -o Tools-repo/Ruleset/Block/BlockEasyListChina.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easylistchina_surge.list"
# ConnersHua
curl -L -o Tools-repo/Ruleset/Block/BlockAdvertising.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Advertising.list"
curl -L -o Tools-repo/Ruleset/Block/BlockMalicious.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Malicious.list"
curl -L -o Tools-repo/Ruleset/Block/BlockTracking.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Tracking.list"

# 本地/局域网
curl -L -o Tools-repo/Ruleset/Other/PrivateIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.list"

# 1Password
curl -L -o Tools-repo/Ruleset/Other/1Password.list "https://gitlab.com/lodepuly/vpn_tool/-/raw/master/Tool/Loon/Rule/1PasswordUS.list"

# PayPal
curl -L -o Tools-repo/Ruleset/Media/PayPal.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/paypal.list"

# AI
curl -L -o Tools-repo/Ruleset/Other/AI.list "https://gitlab.com/lodepuly/vpn_tool/-/raw/master/Tool/Loon/Rule/AI.list"

# 游戏平台
curl -L -o Tools-repo/Ruleset/Other/Steam.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/steam.list"
curl -L -o Tools-repo/Ruleset/Other/Epic.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/epicgames.list"

# 谷歌平台
curl -L -o Tools-repo/Ruleset/Media/YouTube.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/youtube.list"
#curl -L -o Tools-repo/Ruleset/Media/YouTube.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTube.list"
curl -L -o Tools-repo/Ruleset/Media/YouTubeMusic.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTubeMusic.list"
curl -L -o Tools-repo/Ruleset/Other/Google.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/google.list"
curl -L -o Tools-repo/Ruleset/Other/GoogleIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.list"

# 微软平台
curl -L -o Tools-repo/Ruleset/Other/Line.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/line.list"
curl -L -o Tools-repo/Ruleset/Other/GitHub.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/github.list"
curl -L -o Tools-repo/Ruleset/Other/OneDrive.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/onedrive.list"
curl -L -o Tools-repo/Ruleset/Other/Microsoft.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/microsoft.list"

# 社交平台
curl -L -o Tools-repo/Ruleset/Media/Telegram.list "https://raw.githubusercontent.com/Repcz/Tool/X/Surge/Rules/Telegram.list"
curl -L -o Tools-repo/Ruleset/Media/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/twitter.list"
curl -L -o Tools-repo/Ruleset/Media/TwitterIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.list"
curl -L -o Tools-repo/Ruleset/Media/Facebook.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/facebook.list"
curl -L -o Tools-repo/Ruleset/Media/FacebookIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.list"
curl -L -o Tools-repo/Ruleset/Media/Instagram.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/instagram.list"

# 影视媒体
curl -L -o Tools-repo/Ruleset/Media/TikTok.list "https://gitlab.com/lodepuly/vpn_tool/-/raw/master/Tool/Loon/Rule/TikTok.list"
curl -L -o Tools-repo/Ruleset/Media/GlobalMedia.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyMedia.list"
curl -L -o Tools-repo/Ruleset/Media/BilibiliHMT.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/BilibiliHMT.list"
curl -L -o Tools-repo/Ruleset/Media/ChinaMedia.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ChinaMedia.list"
curl -L -o Tools-repo/Ruleset/Media/Bilibili.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/bilibili.list"
curl -L -o Tools-repo/Ruleset/Media/Disney.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/disney.list"
curl -L -o Tools-repo/Ruleset/Media/Netflix.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/netflix.list"
curl -L -o Tools-repo/Ruleset/Media/NetflixIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.list"
curl -L -o Tools-repo/Ruleset/Media/Spotify.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/spotify.list"

# 海外代理
curl -L -o Tools-repo/Ruleset/Other/GlobalGFW.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyGFWlist.list"
curl -L -o Tools-repo/Ruleset/Other/Global.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/geolocation-!cn.list"

# 苹果
curl -L -o Tools-repo/Ruleset/Other/Apple.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/apple.list"
# curl -L -o Tools-repo/Ruleset/Other/Apple.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Apple/Apple.list"
# curl -L -o Tools-repo/Ruleset/Other/AppStore.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Apple/AppStore.list"

# 国内直连
curl -L -o Tools-repo/Ruleset/Other/China.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/cn.list"
# curl -L -o Tools-repo/Ruleset/Other/Direct.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"
curl -L -o Tools-repo/Ruleset/Other/ChinaIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"
curl -L -o Tools-repo/Ruleset/Other/ChinaASN.list "https://raw.githubusercontent.com/missuo/ASN-China/main/ASN.China.list"



#--- ClashMeta ---#
# 本地/局域网
curl -L -o Tools-repo/Ruleset/ClashMeta/Local.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/private.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/LocalIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.list"

# AI
curl -L -o Tools-repo/Ruleset/ClashMeta/Openai.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/openai.list"

# PayPal
curl -L -o Tools-repo/Ruleset/ClashMeta/PayPal.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/paypal.list"

# 苹果
curl -L -o Tools-repo/Ruleset/ClashMeta/Apple.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/apple.list"

# 海外代理
curl -L -o Tools-repo/Ruleset/ClashMeta/Global.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/geolocation-!cn.list"

# 游戏平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Steam.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/steam.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Epic.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/epicgames.list"

# 影视媒体
curl -L -o Tools-repo/Ruleset/ClashMeta/tiktok.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/tiktok.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Bilibili.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/bilibili.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Disney.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/disney.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Netflix.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/NetflixIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Spotify.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/spotify.list"

# 社交平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Facebook.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/facebook.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/FacebookIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Instagram.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/instagram.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/TwitterIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/telegram.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/telegram.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/telegramIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/telegram.list"

# 谷歌平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Google.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/GoogleIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/YouTube.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.list"

# 微软平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Line.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/line.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/GitHub.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/OneDrive.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/onedrive.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Microsoft.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/microsoft.list"

# 国内直连
curl -L -o Tools-repo/Ruleset/ClashMeta/China.list  "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/ChinaIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"


#--- ClashMeta mrs ---#
# 本地/局域网
curl -L -o Tools-repo/Ruleset/ClashMeta/Local.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/private.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/LocalIP.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.mrs"

# AI
curl -L -o Tools-repo/Ruleset/ClashMeta/Openai.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/openai.mrs"

# PayPal
curl -L -o Tools-repo/Ruleset/ClashMeta/PayPal.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/paypal.mrs"

# 苹果
curl -L -o Tools-repo/Ruleset/ClashMeta/Apple.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/apple.mrs"

# 海外代理
curl -L -o Tools-repo/Ruleset/ClashMeta/Global.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/geolocation-!cn.mrs"

# 游戏平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Steam.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/steam.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/Epic.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/epicgames.mrs"

# 影视媒体
curl -L -o Tools-repo/Ruleset/ClashMeta/tiktok.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/tiktok.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/Bilibili.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/bilibili.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/Disney.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/disney.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/Netflix.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/NetflixIP.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/Spotify.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/spotify.mrs"

# 社交平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Facebook.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/facebook.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/FacebookIP.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/Instagram.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/instagram.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/Twitter.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/TwitterIP.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/telegram.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/telegram.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/telegramIP.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/telegram.mrs"

# 谷歌平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Google.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/GoogleIP.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/YouTube.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.mrs"

# 微软平台
curl -L -o Tools-repo/Ruleset/ClashMeta/Line.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/line.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/GitHub.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/OneDrive.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/onedrive.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/Microsoft.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/microsoft.mrs"

# 国内直连
curl -L -o Tools-repo/Ruleset/ClashMeta/China.mrs  "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.mrs"
curl -L -o Tools-repo/Ruleset/ClashMeta/ChinaIP.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.mrs"
