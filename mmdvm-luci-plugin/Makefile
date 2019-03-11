#
# Copyright 2019 BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=mmdvm-luci-plugin
PKG_VERSION:=1.0.2
PKG_RELEASE:=1
GIT_REVISION:=$(shell git rev-parse --short HEAD)
PKG_REVISION:=$(PKG_VERSION)-$(PKG_RELEASE)-$(GIT_REVISION)
# PKG_BUILD_DEPENDS += $(LUCI_BUILD_DEPENDS)
PKG_BUILD_DEPENDS:=
PKG_CONFIG_DEPENDS += CONFIG_LUCI_APP_MMDVM_SRCDIET
# PKG_FILE_DEPENDS:=
PKG_LICENSE:=GPL-2.0

PKG_MAINTAINER:=BD7MQB <bd7mqb@qq.com>

include $(INCLUDE_DIR)/package.mk

HTDOCS = /www
LUA_LIBRARYDIR = /usr/lib/lua
LUCI_LIBRARYDIR = $(LUA_LIBRARYDIR)/luci

define Package/${PKG_NAME}
	SECTION:=net
	CATEGORY:=MMDVM
	#SUBMENU:=Misc
	TITLE:=MMDVM's LuCI plugins.
	DEPENDS:=+luci +mmdvm-host +libubus-lua +libubox-lua
	#VERSION:=$(PKG_RELEASE)-$(REVISION)
endef


define Package/${PKG_NAME}/config
	config LUCI_APP_MMDVM
	bool "luci-app-mmdvm"
	depends on PACKAGE_mmdvm-luci-plugin
	default y
	help
	  "LuCI plugin to configurate MMDVM Radio"

	config LUCI_APP_MMDVM_SRCDIET
	bool "Minify MMDVM Lua sources"
	depends on PACKAGE_mmdvm-luci-plugin
	default y
	help
	  "Minify Lua sources"
endef

define Build/Compile

endef

define SrcDiet
	$(FIND) $(1) -type f -name '*.lua' | while read src; do \
		if LUA_PATH="$(STAGING_DIR_HOSTPKG)/lib/lua/5.1/?.lua" luasrcdiet --noopt-binequiv -o "$$$$src.o" "$$$$src"; \
		then mv "$$$$src.o" "$$$$src"; fi; \
	done
endef

define SubstituteVersion
	$(FIND) $(1) -type f -name '*.htm' | while read src; do \
		$(SED) 's/<%# *\([^ ]*\)PKG_REVISION *%>/\1$(PKG_REVISION)/g' \
		    -e 's/"\(<%= *\(media\|resource\) *%>[^"]*\.\(js\|css\)\)"/"\1?v=$(PKG_REVISION)"/g' \
			"$$$$src"; \
	done
endef

define Package/common/install
	if [ -d $(2)/luasrc ]; then \
	  $(INSTALL_DIR) $(1)$(LUCI_LIBRARYDIR); \
	  cp -pR ./$(2)/luasrc/* $(1)$(LUCI_LIBRARYDIR)/; \
		$(FIND) $(1)$(LUCI_LIBRARYDIR)/ -type f -name '*.luadoc' | $(XARGS) rm; \
	  $(if $(CONFIG_LUCI_APP_MMDVM_SRCDIET),$(call SrcDiet,$(1)$(LUCI_LIBRARYDIR)/),true); \
		$(call SubstituteVersion,$(1)$(LUCI_LIBRARYDIR)/); \
	else true; fi
	if [ -d $(2)/htdocs ]; then \
	  $(INSTALL_DIR) $(1)$(HTDOCS); \
	  cp -pR ./$(2)/htdocs/* $(1)$(HTDOCS)/; \
	else true; fi
	if [ -d $(2)/root ]; then \
	  $(INSTALL_DIR) $(1)/; \
	  cp -pR ./$(2)/root/* $(1)/; \
		$(if $(CONFIG_LUCI_APP_MMDVM_SRCDIET),$(call SrcDiet,$(1)/),true); \
		mv $(1)/usr/sbin/dmrid.lua $(1)/usr/sbin/dmrid; \
		chmod 750 $(1)/usr/sbin/dmrid; \
	else true; fi
	if [ -d $(2)/src ]; then \
	  $(call Build/Install/Default) \
	  $(CP) ./$(PKG_INSTALL_DIR)/* $(1)/; \
	else true; fi
endef


define Package/${PKG_NAME}/install
	$(call Package/common/install,$(1),luci-app-mmdvm)
endef

define Package/${PKG_NAME}postinst
#!/bin/sh
if [ -e /etc/openwrt_release ]; then
	[ -f /etc/init.d/dmrid ] && /etc/init.d/dmrid enable || :
fi
exit 0
endef

$(eval $(call BuildPackage,${PKG_NAME}))