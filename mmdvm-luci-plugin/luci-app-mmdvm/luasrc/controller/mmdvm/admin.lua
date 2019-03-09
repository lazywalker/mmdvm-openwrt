-- Copyright 2019 BD7MQB (bd7mqb@qq.com)
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
	entry({"admin", "services", "mmdvm"}, firstchild(), _("MMDVM"), 30).dependent = false
	entry({"admin", "services", "mmdvm", "log"}, template("mmdvm/logread"), _("View Logfile"), 20).leaf = true
	entry({"admin", "services", "mmdvm", "advanced"}, firstchild(), _("Advanced"), 100)
	entry({"admin", "services", "mmdvm", "advanced", "mmdvmhost"}, form("mmdvm/mmdvmhost_tab"), _("Edit MMDVM.ini"), 110).leaf = true
	entry({"admin", "services", "mmdvm", "advanced", "ysfgateway"}, form("mmdvm/ysfgateway_tab"), _("Edit YSFGateway.ini"), 120).leaf = true
	entry({"admin", "services", "mmdvm", "advanced", "p25gateway"}, form("mmdvm/p25gateway_tab"), _("Edit P25Gateway.ini"), 130).leaf = true
end

function logread(n)
	if not n then n = 1 end

	local content
	local cmd = "tail -n +%s /var/log/mmdvm/MMDVM-%s.log" % {n, os.date("%Y-%m-%d")}
	content = util.trim(util.exec(cmd))
	
	-- if content == "" then
	-- 	content = "No MMDVM related logs yet!"
	-- end
	http.write(content)
end
