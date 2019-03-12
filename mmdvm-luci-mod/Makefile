#
# Copyright 2019 BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mmdvm-luci-mod
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
GIT_REVISION:=$(shell git rev-parse --short HEAD)
PKG_REVISION:=$(PKG_VERSION)-$(PKG_RELEASE)-$(GIT_REVISION)
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=BD7MQB <bd7mqb@qq.com>

include $(INCLUDE_DIR)/package.mk

define Package/${PKG_NAME}
	SECTION:=net
	CATEGORY:=MMDVM
	TITLE:=MMDVM LuCI Mod
	URL:=
	DEPENDS:=luci
endef

define Package/${PKG_NAME}/description
This Mod is intent to hide some `route` modules of LuCI to make it more easer to use with MMDVM Suite
endef

define Build/Compile

endef

define Package/${PKG_NAME}/install
	$(CP) -a files/* $(1)/
endef

define Package/${PKG_NAME}/postinst
#!/bin/sh
mv /usr/lib/lua/luci/dispatcher.lua /usr/lib/lua/luci/dispatcher.lua_origin
mv /usr/lib/lua/luci/dispatcher.lua.mod /usr/lib/lua/luci/dispatcher.lua

rm -rf /tmp/luci-*
exit 0
endef

define Package/${PKG_NAME}/prerm
#!/bin/sh
mv /usr/lib/lua/luci/dispatcher.lua_origin /usr/lib/lua/luci/dispatcher.lua
rm -rf /tmp/luci-*

exit 0
endef

$(eval $(call BuildPackage,${PKG_NAME}))