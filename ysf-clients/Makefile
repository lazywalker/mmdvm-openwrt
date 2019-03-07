#
# Copyright (C) 2008-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ysf-clients
PKG_REV:=HEAD
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/lazywalker/YSFClients
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=git
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/ysf-clients
	SECTION:=net
	CATEGORY:=MMDVM
	TITLE:=MMDVM YSFClients
	URL:=$(PKG_SOURCE_URL)
	DEPENDS:=+libpthread +libstdcpp
endef

define Package/ysf-clients/description
System Fusion network servers, including gateway and parrot.
endef

TARGET_CFLAGS += -std=c++0x -DOPENWRT=1

TARGET_LDFLAGS += \
        -Wl,-rpath-link=$(STAGING_DIR)/usr/lib \

MAKE_FLAGS +=\
        CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS)" \

define Package/ysf-clients/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/YSFGateway/YSFGateway $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/YSFParrot/YSFParrot $(1)/usr/sbin/
	$(CP) -a files/* $(1)/
endef

define Package/ysf-clients/conffiles
/etc/YSFGateway.ini
endef

define Package/ysf-clients/postinst
#!/bin/sh
if [ -e /etc/openwrt_release ]; then
	[ -f /etc/init.d/ysfgateway ] && /etc/init.d/ysfgateway enable || :
	[ -f /etc/init.d/ysfparrot ] && /etc/init.d/ysfparrot enable || :
fi
exit 0
endef

$(eval $(call BuildPackage,ysf-clients))
