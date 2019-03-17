-- Copyright 2019 BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

module("luci.controller.mmdvm.admin", package.seeall)

local sys   = require("luci.sys")
local util  = require("luci.util")
local http  = require("luci.http")
local i18n  = require("luci.i18n")
local json  = require("luci.jsonc")
local uci   = require("luci.model.uci").cursor()

function index()
	if not nixio.fs.access("/etc/MMDVM.ini") then
		return
	end
	entry({"admin", "mmdvm"}, firstchild(), _("MMDVM"), 30).dependent = false
	entry({"admin", "mmdvm", "config"}, firstchild(), _("Configuration"), 40).index = true
	entry({"admin", "mmdvm", "config", "general"}, cbi("mmdvm/config_general"), _("General"), 41)
	entry({"admin", "mmdvm", "config", "dvmode"}, cbi("mmdvm/config_dvmode"), _("Digital Modes"), 42)
	entry({"admin", "mmdvm", "advanced"}, firstchild(), _("Advanced"), 100)
	entry({"admin", "mmdvm", "advanced", "mmdvmhost"}, form("mmdvm/mmdvmhost_tab"), _("Edit MMDVM.ini"), 110).leaf = true
	entry({"admin", "mmdvm", "advanced", "ysfgateway"}, form("mmdvm/ysfgateway_tab"), _("Edit YSFGateway.ini"), 120).leaf = true
	entry({"admin", "mmdvm", "advanced", "p25gateway"}, form("mmdvm/p25gateway_tab"), _("Edit P25Gateway.ini"), 130).leaf = true	entry({"admin", "mmdvm", "log"}, template("mmdvm/logread"), _("Live Log"), 999).leaf = true
	entry({"admin", "mmdvm", "log"}, template("mmdvm/logread"), _("Live Log"), 999).leaf = true
end

