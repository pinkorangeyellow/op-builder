#!/bin/bash
set -uo pipefail

#=================================================
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#

# 修改openwrt登陆地址,把下面的192.168.2.2修改成你想要的就可以了
# sed -i 's/192.168.1.1/192.168.2.2/g' package/base-files/files/bin/config_generate

# 设置密码为空
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings

rustup update
sed -i 's/option lang auto/option lang zh_cn/' feeds/luci/modules/luci-base/root/etc/config/luci

###########################
