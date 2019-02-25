# Copyright 2019 BD7MQB (bd7mqb@qq.com)
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=mmdvm-luci-plugin
PKG_VERSION:=1.0.0
PKG_RELEASE:=$(shell git rev-parse --short HEAD)
# PKG_BUILD_DEPENDS:=base-files
# PKG_FILE_DEPENDS:=
PKG_LICENSE:=GPL-2.0

PKG_MAINTAINER:=BD7MQB <bd7mqb@qq.com>

include $(INCLUDE_DIR)/package.mk

HTDOCS = /www
LUA_LIBRARYDIR = /usr/lib/lua
LUCI_LIBRARYDIR = $(LUA_LIBRARYDIR)/luci

define Package/mmdvm-luci-plugin
	SECTION:=net
	CATEGORY:=MMDVM
	#SUBMENU:=Misc
	TITLE:=MMDVM's LuCI plugins.
	DEPENDS:=+luci +mmdvm-host
	#VERSION:=$(PKG_RELEASE)-$(REVISION)
endef


define Package/mmdvm-luci-plugin/config
	config LUCI_APP_MMDVM
	bool "luci-app-mmdvm"
	depends on PACKAGE_mmdvm-luci-plugin
	default y
	help
	  "LuCI plugin to configurate MMDVM Radio"
endef

define Build/Compile

endef

define Package/common/install
	if [ -d $(2)/luasrc ]; then \
	  $(INSTALL_DIR) $(1)$(LUCI_LIBRARYDIR); \
	  cp -pR ./$(2)/luasrc/* $(1)$(LUCI_LIBRARYDIR)/; \
	else true; fi
	if [ -d $(2)/htdocs ]; then \
	  $(INSTALL_DIR) $(1)$(HTDOCS); \
	  cp -pR ./$(2)/htdocs/* $(1)$(HTDOCS)/; \
	else true; fi
	if [ -d $(2)/root ]; then \
	  $(INSTALL_DIR) $(1)/; \
	  cp -pR ./$(2)/root/* $(1)/; \
	else true; fi
	if [ -d $(2)/src ]; then \
	  $(call Build/Install/Default) \
	  $(CP) ./$(PKG_INSTALL_DIR)/* $(1)/; \
	else true; fi
endef


define Package/mmdvm-luci-plugin/install
	$(call Package/common/install,$(1),luci-app-mmdvm)
endef


$(eval $(call BuildPackage,mmdvm-luci-plugin))