-- Copyright 2019 BD7MQB (bd7mqb@qq.com)
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2

module("luci.controller.mmdvm.public", package.seeall)

local sys   = require("luci.sys")
local util  = require("luci.util")
local http  = require("luci.http")
local i18n  = require("luci.i18n")
local json  = require("luci.jsonc")
local uci   = require("luci.model.uci").cursor()
local mmdvm = require("luci.model.mmdvm")

function index()
	if not nixio.fs.access("/etc/MMDVM.ini") then
		return
	end
	entry({"mmdvm"}, firstchild(), _("MMDVM"), 1).dependent = false
	entry({"mmdvm", "dashboard"}, call("action_dashboard"), _("Dashboard"), 10).leaf = true
	entry({"mmdvm", "log"}, template("mmdvm/logread"), _("Live Log"), 20).leaf = true
	entry({"mmdvm", "logread"}, call("action_logread"), nil).leaf = true
	entry({"mmdvm", "lastheard"}, call("action_lastheard"), nil).leaf = true
	entry({"mmdvm", "livedisplay"}, template("mmdvm/livedisplay"))

end

function action_logread(n)
	if not n then n = 1 end

	local content
	local cmd = "tail -n +%s /var/log/mmdvm/MMDVM-%s.log" % {n, os.date("%Y-%m-%d")}
	content = util.trim(util.exec(cmd))
	http.write(content)
end

function action_dashboard()
	local lastheard = mmdvm.get_lastheard()
	luci.template.render("mmdvm/dashboard", {lastheard = lastheard} )
end

function action_lastheard()
	local lastheard = mmdvm.get_lastheard()
	luci.template.render("mmdvm/lastheard", {lastheard = lastheard} )
end
