#
# Copyright 2019 BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=luci-mod-admin-mmdvm
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
GIT_REVISION:=$(shell git rev-parse --short HEAD)
PKG_REVISION:=$(PKG_VERSION)-$(PKG_RELEASE)-$(GIT_REVISION)
# PKG_BUILD_DEPENDS += $(LUCI_BUILD_DEPENDS)
PKG_BUILD_DEPENDS:=
PKG_CONFIG_DEPENDS += CONFIG_LUCI_SRCDIET
# PKG_FILE_DEPENDS:=
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=BD7MQB <bd7mqb@qq.com>

include $(INCLUDE_DIR)/package.mk

HTDOCS = /www
LUA_LIBRARYDIR = /usr/lib/lua
LUCI_LIBRARYDIR = $(LUA_LIBRARYDIR)/luci

define Package/${PKG_NAME}
	SECTION:=mmdvm
	CATEGORY:=MMDVM
	#SUBMENU:=Misc
	TITLE:=LuCI Administration - compat-featured
	DEPENDS:=+iwinfo +luci-compat +libubus-lua +libubox-lua
endef

define Package/${PKG_NAME}/description
LuCI Administration - compat-featured for mmdvm control
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

define Package/$(PKG_NAME)/install
	if [ -d ./luasrc ]; then \
	  $(INSTALL_DIR) $(1)$(LUCI_LIBRARYDIR); \
	  cp -pR ./luasrc/* $(1)$(LUCI_LIBRARYDIR)/; \
	  $(FIND) $(1)$(LUCI_LIBRARYDIR)/ -type f -name '*.luadoc' | $(XARGS) rm; \
	  $(if $(CONFIG_LUCI_SRCDIET),$(call SrcDiet,$(1)$(LUCI_LIBRARYDIR)/),true); \
	  $(call SubstituteVersion,$(1)$(LUCI_LIBRARYDIR)/); \
	else true; fi
	if [ -d ./htdocs ]; then \
	  $(INSTALL_DIR) $(1)$(HTDOCS); \
	  cp -pR ./htdocs/* $(1)$(HTDOCS)/; \
	else true; fi
	if [ -d ./root ]; then \
	  $(INSTALL_DIR) $(1)/; \
	  cp -pR ./root/* $(1)/; \
	else true; fi
	if [ -d ./src ]; then \
	  $(call Build/Install/Default) \
	  $(CP) $(PKG_INSTALL_DIR)/* $(1)/; \
	else true; fi
endef

$(eval $(call BuildPackage,${PKG_NAME}))