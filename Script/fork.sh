# 2024-06-28 12:30

#!/bin/bash

# 创建规则目录
mkdir -p Tools/{Ruleset,Transfer}/{ClashMeta}

#--- Surge ---#
# Other
curl -L -o Tools-repo/Transfer/AI.list "https://gitlab.com/lodepuly/vpn_tool/-/raw/master/Tool/Loon/Rule/AI.list"
curl -L -o Tools-repo/Transfer/China.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/cn.list"
curl -L -o Tools-repo/Transfer/ChinaIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/classical/cn.list"
curl -L -o Tools-repo/Transfer/Google.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/Google.list"
curl -L -o Tools-repo/Transfer/GoogleCN.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/GoogleCN.list"
curl -L -o Tools-repo/Transfer/GoogleCNProxyIP.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/GoogleCNProxyIP.list"
curl -L -o Tools-repo/Transfer/GoogleEarth.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/GoogleEarth.list"
curl -L -o Tools-repo/Transfer/GoogleFCM.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/GoogleFCM.list"
curl -L -o Tools-repo/Transfer/GoogleIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/classical/google.list"
curl -L -o Tools-repo/Transfer/GlobalGFW.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyGFWlist.list"

# Media
curl -L -o Tools-repo/Transfer/Bilibili.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/bilibili.list"
curl -L -o Tools-repo/Transfer/BilibiliHMT.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/BilibiliHMT.list"
curl -L -o Tools-repo/Transfer/ChinaMedia.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ChinaMedia.list"
curl -L -o Tools-repo/Transfer/DisneyPlus.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/DisneyPlus.list"
curl -L -o Tools-repo/Transfer/GlobalMedia.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyMedia.list"
curl -L -o Tools-repo/Transfer/Transfer/Netflix.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/netflix.list"
curl -L -o Tools-repo/Transfer/Transfer/NetflixIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/classical/netflix.list"
curl -L -o Tools-repo/Transfer/Spotify.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/Spotify.list"
curl -L -o Tools-repo/Transfer/TikTok.list "https://gitlab.com/lodepuly/vpn_tool/-/raw/master/Tool/Loon/Rule/TikTok.list"
curl -L -o Tools-repo/Transfer/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/classical/twitter.list"
curl -L -o Tools-repo/Transfer/TwitterIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/classical/twitter.list"
curl -L -o Tools-repo/Transfer/Facebook.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/Facebook.list"
curl -L -o Tools-repo/Transfer/Instagram.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/Instagram.list"
curl -L -o Tools-repo/Transfer/YouTube.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTube.list"
curl -L -o Tools-repo/Transfer/YouTubeMusic.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTubeMusic.list"

# Block
curl -L -o Tools-repo/Transfer/BlockAds.list "https://raw.githubusercontent.com/RuCu6/QuanX/main/Rules/MyBlockAds.list"
curl -L -o Tools-repo/Transfer/BlockAdg.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanAD.list"
curl -L -o Tools-repo/Transfer/BlockAdb.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/Surge/rule/Adblock4limbo_surge.list"
curl -L -o Tools-repo/Transfer/BlockPrivacy.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easyprivacy_surge.list"
curl -L -o Tools-repo/Transfer/BlockEasyListChina.list "https://raw.githubusercontent.com/limbopro/Adblock4limbo/main/rule/Surge/easylistchina_surge.list"
curl -L -o Tools-repo/Transfer/BlockAdvertising.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Advertising.list"
curl -L -o Tools-repo/Transfer/BlockHijacking.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Hijacking.list"
curl -L -o Tools-repo/Transfer/BlockTracking.list "https://raw.githubusercontent.com/ConnersHua/RuleGo/master/Surge/Ruleset/Extra/Reject/Tracking.list"

#--- Transfer ---#
#classical

# domain
curl -L -o Tools-repo/Ruleset/ClashMeta/Bilibili.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/bilibili.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/China.list  "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/GitHub.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Google.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Netflix.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/YouTube.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.list"

# ipcidr
curl -L -o Tools-repo/Ruleset/ClashMeta/ChinaIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/GoogleIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/NetflixIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.list"
curl -L -o Tools-repo/Ruleset/ClashMeta/TwitterIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.list"
