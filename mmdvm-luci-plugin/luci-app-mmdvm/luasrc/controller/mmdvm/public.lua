-- Copyright 2019 BD7MQB (bd7mqb@qq.com)
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2

module("luci.controller.mmdvm.public", package.seeall)

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
	entry({"mmdvm"}, firstchild(), _("MMDVM"), 30).dependent = false
	entry({"mmdvm", "dashboard"}, template("mmdvm/dashboard"), _("Dashboard"), 20).leaf = true
	entry({"mmdvm", "log"}, template("mmdvm/logread"), _("Live Log"), 10).leaf = true
	entry({"mmdvm", "logread"}, call("logread"), nil).leaf = true
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
