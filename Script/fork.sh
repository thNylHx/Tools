# 2024-06-10 21:15

#!/bin/bash

# 创建规则目录
mkdir -p Tools/Ruleset/{Block,Media,Other}

#--- Surge ---#

# 代理
curl -L -o Tools-repo/Ruleset/GlobalGFW.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyGFWlist.list"

# AI
curl -L -o Tools-repo/Ruleset/Other/AI.list "https://gitlab.com/lodepuly/vpn_tool/-/raw/master/Tool/Loon/Rule/AI.list"

# IP
curl -L -o Tools-repo/Ruleset/Other/ChinaIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"

# 媒体
curl -L -o Tools-repo/Ruleset/Media/GlobalMedia.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/ProxyMedia.list"
curl -L -o Tools-repo/Ruleset/Media/TikTok.list "https://gitlab.com/lodepuly/vpn_tool/-/raw/master/Tool/Loon/Rule/TikTok.list"
#curl -L -o Tools-repo/Ruleset/Media/YouTube.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTube.list"
#curl -L -o Tools-repo/Ruleset/Media/YouTubeMusic.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/Ruleset/YouTubeMusic.list"


# 广告
curl -L -o Tools-repo/Ruleset/Block/BlockAds.list "https://raw.githubusercontent.com/RuCu6/QuanX/main/Rules/MyBlockAds.list"
curl -L -o Tools-repo/Ruleset/Block/BlockAdg.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanAD.list"
curl -L -o Tools-repo/Ruleset/Block/BlockEasyList.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanEasyList.list"
curl -L -o Tools-repo/Ruleset/Block/BlockPrivacy.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanEasyPrivacy.list"
curl -L -o Tools-repo/Ruleset/Block/BlockProgram.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanProgramAD.list"
curl -L -o Tools-repo/Ruleset/Block/BlockEasyListChina.list "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanEasyListChina.list"
