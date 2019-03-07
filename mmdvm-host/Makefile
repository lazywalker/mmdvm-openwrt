#
# Copyright (C) 2008-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mmdvm-host
PKG_REV:=HEAD
PKG_VERSION:=1.0.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/lazywalker/MMDVMHost
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=git
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/mmdvm-host
	SECTION:=net
	CATEGORY:=MMDVM
	TITLE:=MMDVM Host
	URL:=https://github.com/g4klx/MMDVMHost/
	DEPENDS:=+libpthread +libstdcpp +ysf-clients +p25-clients
endef

define Package/mmdvm-host/description
The host program for the MMDVM
endef

TARGET_CFLAGS += -std=c++0x -DOPENWRT=1

ifeq ($(ARCH),mips)
	TARGET_CFLAGS += -DWORDS_BIGENDIAN=1
	TARGET_CPPFLAGS += -DWORDS_BIGENDIAN=1
endif

TARGET_LDFLAGS += \
    -Wl,-rpath-link=$(STAGING_DIR)/usr/lib \

MAKE_FLAGS +=\
    CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
    LDFLAGS="$(TARGET_LDFLAGS)" \

define Package/mmdvm-host/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/MMDVMHost $(1)/usr/sbin/
	$(CP) -a files/* $(1)/
endef

define Package/mmdvm-host/conffiles
/etc/MMDVM.ini
endef

define Package/mmdvm-host/postinst
#!/bin/sh
if [ -e /etc/openwrt_release ]; then
	[ -f /etc/init.d/mmdvmhost ] && /etc/init.d/mmdvmhost enable || :
fi
exit 0
endef

$(eval $(call BuildPackage,mmdvm-host))