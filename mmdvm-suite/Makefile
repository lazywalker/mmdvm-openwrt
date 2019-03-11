#
# Copyright 2019 BD7MQB (bd7mqb@qq.com)
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mmdvm-suite
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
	TITLE:=MMDVM Suite
	URL:=
	DEPENDS:=+mmdvm-luci-plugin +mmdvm-host
endef

define Package/${PKG_NAME}/description
The MMDVM Suite for OpenWrt
endef

define Build/Compile

endef

define Package/${PKG_NAME}/install
	$(CP) -a files/* $(1)/
endef

define Package/${PKG_NAME}/postinst
#!/bin/sh
if [ -e /etc/openwrt_release ]; then
	mv /usr/sbin/mmdvm-update.sh /usr/sbin/mmdvm-update
	chown root.root /usr/sbin/mmdvm-update
	chmod 750 /usr/sbin/mmdvm-update
fi
exit 0
endef

$(eval $(call BuildPackage,${PKG_NAME}))