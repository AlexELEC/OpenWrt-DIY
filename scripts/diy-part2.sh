#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Clone community packages to package/community
mkdir package/community
pushd package/community

# Add luci-app-diskman
git clone --depth=1 https://github.com/SuLingGG/luci-app-diskman
mkdir parted
cp luci-app-diskman/Parted.Makefile parted/Makefile

# Add luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config
rm -rf ../lean/luci-theme-argon

# Add extra wireless drivers
#svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl8812au-ac
#svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl8821cu
#svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl8188eu
#svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl88x2bu

# Add apk (Apk Packages Manager)
svn co https://github.com/openwrt/packages/trunk/utils/apk
popd

# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
export orig_version="$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')"
sed -i "s/${orig_version}/${orig_version} ($(date +"%Y-%m-%d"))/g" zzz-default-settings
popd

# Use Lienol's https-dns-proxy package
pushd feeds/packages/net
rm -rf https-dns-proxy
svn co https://github.com/Lienol/openwrt-packages/trunk/net/https-dns-proxy
popd

# Use snapshots' syncthing package
pushd feeds/packages/utils
rm -rf syncthing
svn co https://github.com/openwrt/packages/trunk/utils/syncthing
popd

# Fix mt76 wireless driver
pushd package/kernel/mt76
sed -i '/mt7662u_rom_patch.bin/a\\techo mt76-usb disable_usb_sg=1 > $\(1\)\/etc\/modules.d\/mt76-usb' Makefile
popd

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# create /opt
sed -i "/\/usr\/bin\/ip/a mkdir \/opt" package/lean/default-settings/files/zzz-default-settings

# Modify vesrsion
sed -i '/uci commit system/i\uci set system.@system[0].hostname='RouterAE'' package/lean/default-settings/files/zzz-default-settings
sed -i "s/OpenWrt /AlexELEC build $(TZ=UTC+3 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

# Modify default language, timezone
sed -i "s/uci set luci\.main\.lang\=zh_cn/uci set luci\.main\.lang\=en/g" package/lean/default-settings/files/zzz-default-settings
sed -i "s/uci set system\.@system\[0\]\.timezone\=CST\-8/uci set system\.@system\[0\]\.timezone\='EET\-2EEST\,M3\.5\.0\/3\,M10\.5\.0\/4'/g" package/lean/default-settings/files/zzz-default-settings
sed -i "s/uci set system\.@system\[0\]\.zonename\=Asia\/Shanghai/uci set system\.@system\[0\]\.zonename\='Europe\/Kiev'/g" package/lean/default-settings/files/zzz-default-settings

sed -i "/uci commit system/i uci set system.ntp.server=''" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit system/i uci add_list system.ntp.server=time.windows.com" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit system/i uci add_list system.ntp.server=1.europe.pool.ntp.org" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit system/i uci add_list system.ntp.server=2.europe.pool.ntp.org" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit system/i uci add_list system.ntp.server=3.europe.pool.ntp.org" package/lean/default-settings/files/zzz-default-settings

sed -i "/uci commit system/a uci commit ntpclient" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit ntpclient/i uci set ntpclient.@ntpserver[3].hostname='3.europe.pool.ntp.org'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit ntpclient/i uci set ntpclient.@ntpserver[2].hostname='2.europe.pool.ntp.org'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit ntpclient/i uci set ntpclient.@ntpserver[1].hostname='1.europe.pool.ntp.org'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit ntpclient/i uci set ntpclient.@ntpserver[0].hostname='time.windows.com'" package/lean/default-settings/files/zzz-default-settings

# Modify luci default language
sed -i "s/set luci\.main\.lang\=zh_cn/set luci\.main\.lang\=en/g" feeds/luci/modules/luci-base/root/etc/uci-defaults/luci-base
