# 2024-06-10 21:15

#!/bin/bash

# 创建规则目录
mkdir -p Tools/Ruleset/{Block,Media,Other}

#--- Surge ---#

# Other
curl -L -o Tools-repo/Ruleset/ChinaIP.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"
