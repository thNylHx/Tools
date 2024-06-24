# 2024-06-10 21:15

#!/bin/bash

# 创建规则目录
mkdir -p Collect/Ruleset/{Block,MediaOther}

#--- Surge ---#

# 广告规则 
curl -L -o Collect-repo/Ruleset/Block/AdsBlock.list "https://raw.githubusercontent.com/RuCu6/QuanX/main/Rules/MyBlockAds.list"
