# 2024-06-27 20:20

#!/bin/bash

# 创建规则目录
mkdir -p Tools/Meta/Ruleset

#--- Meta ---#

# 
curl -L -o Tools-repo/Meta/Ruleset/China.list  "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.list"
curl -L -o Tools-repo/Meta/Ruleset/GoogleIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.list"
curl -L -o Tools-repo/Meta/Ruleset/YouTube.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.list"
curl -L -o Tools-repo/Meta/Ruleset/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.list"


# IP
curl -L -o Tools-repo/Meta/Ruleset/ChinaIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"
curl -L -o Tools-repo/Meta/Ruleset/GoogleIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.list"
curl -L -o Tools-repo/Meta/Ruleset/TwitterIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.list"
