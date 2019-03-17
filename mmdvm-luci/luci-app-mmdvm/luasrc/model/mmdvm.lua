-- Copyright 2019 BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

local util  = require "luci.util"
local fs = require "nixio.fs"
local json = require "luci.jsonc"
local os = os
local io = io
local table = table
local string = string
local tonumber  = tonumber
local print = print
local type = type
local assert = assert
local pairs = pairs
local ipairs = ipairs
local tostring = tostring

module "luci.model.mmdvm"

MMDVMHOST_CONFFILE = "/etc/MMDVM.ini"
YSFGATEWAY_CONFFILE = "/etc/YSFGateway.ini"
P25GATEWAY_CONFFILE = "/etc/P25Gateway.ini"
UCI_CONFFILE = "/etc/config/mmdvm"


--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function ini_load(fileName)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
	local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
	local data = {};
	local section;
	for line in file:lines() do
		local tempSection = line:match('^%[([^%[%]]+)%]$');
		if(tempSection)then
			section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
			data[section] = data[section] or {};
		end
		local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
		if(param and value ~= nil)then
			if(tonumber(value))then
				value = tonumber(value);
			elseif(value == 'true')then
				value = true;
			elseif(value == 'false')then
				value = false;
			end
			if(tonumber(param))then
				param = tonumber(param);
			end
			data[section][param] = value;
		end
	end
	file:close();
	-- Last Last modification timestamp
	data[".mtime"] = fs.stat(fileName, "mtime")
	return data;
end

--- Saves all the data from a table to an INI file.
--@param fileName The name of the INI file to fill. [string]
--@param data The table containing all the data to store. [table]
function ini_save(fileName, data)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
	assert(type(data) == 'table', 'Parameter "data" must be a table.');
	local file = assert(io.open(fileName, 'w+b'), 'Error loading file :' .. fileName);
	local contents = '';
	for section, param in pairs(data) do
		if section ~= ".mtime" then
			contents = contents .. ('[%s]\n'):format(section);
			for key, value in pairs(param) do
				contents = contents .. ('%s=%s\n'):format(key, tostring(value));
			end
			contents = contents .. '\n';
		end
	end
	file:write(contents);
	file:close();
end

--- Ini to uci synchornize
--- When ini file is updated manualy, the uci file will be sync by running this function
-- @params muci uci instance, typically ref of a Map.uci at cbi
function ini2uci(muci)
	-- http.write_json(conf)
	local mmdvmhost_conf_setions_needed = {
			General = {"Callsign", "Id", "Duplex", "NetModeHang", "RFModeHang"}, 
			Info = {"RXFrequency", "TXFrequency", "Latitude", "Longitude", "Power", "Height", "Location", "Description", "URL"}, 
			Modem = {"Port", "RXOffset", "TXOffset", "RSSIMappingFile"}, 
			DMR = {"Enable", "ColorCode", "SelfOnly", "DumpTAData"}, 
			DMR_Network = {"Address"}, 
			System_Fusion = {"Enable", "SelfOnly"}, 
			System_Fusion_Network = {"Enable"},
			P25 = {"Enable", "NAC", "SelfOnly", "OverrideUIDCheck"},
			P25_Network = {"Enable"}
		}
	local updated = false
	local mmdvmhost_conf = ini_load(MMDVMHOST_CONFFILE)
	local ysfgateway_conf = ini_load(YSFGATEWAY_CONFFILE)
	local p25gateway_conf = ini_load(P25GATEWAY_CONFFILE)

	-- initialize /etc/config/mmdvm
	-- mmdvmhost
	local uci_mtime = fs.stat(UCI_CONFFILE, "mtime")
	for section, options in pairs(mmdvmhost_conf_setions_needed) do
		local sename = section:gsub("_", " ")
		if mmdvmhost_conf[sename] then
			for _, option in ipairs(options) do
				if not muci:get("mmdvm", section, option) or mmdvmhost_conf[".mtime"] > uci_mtime then
					local o = {[option] = mmdvmhost_conf[sename][option]}
					muci:section("mmdvm", "mmdvmhost", section, o)
					log(("init %s/mmdvmhost/%s/%s"):format(UCI_CONFFILE, section, json.stringify(o)))
					updated = true
				end
			end
		end
	end
	--
	-- ysfgateway
	local sename = "Network"
	local section = "YSFG_Network"
	local options = {"Startup", "InactivityTimeout", "Revert"}
	for _, option in ipairs(options) do
		if not muci:get("mmdvm", section, option) or ysfgateway_conf[".mtime"] > uci_mtime then
			local o = {[option] = ysfgateway_conf[sename][option]}
			muci:section("mmdvm", "ysfgateway", section, o)
			log(("init %s/ysfgateway/%s/%s"):format(UCI_CONFFILE, section, json.stringify(o)))
			updated = true
		end
	end
	--
	-- p25gateway
	local sename = "Network"
	local section = "P25G_Network"
	local options = {"Startup", "InactivityTimeout", "Revert"}
	for _, option in ipairs(options) do
		if not muci:get("mmdvm", section, option) or p25gateway_conf[".mtime"] > uci_mtime then
			local o = {[option] = p25gateway_conf[sename][option]}
			muci:section("mmdvm", "p25gateway", section, o)
			log(("init %s/p25gateway/%s/%s"):format(UCI_CONFFILE, section, json.stringify(o)))
			updated = true
		end
	end
	
	if updated then
		muci:save("mmdvm")
		muci:commit("mmdvm")
	end	
end

--- Uci to ini synchornize
--@param changes as [["set","Info","Latitude","22.1"],["set","Info","Longitude","114.3"],["set","Modem","RXOffset","100"],["set","Info","Latitude","22.10"],["set","Info","Longitude","114.30"],["set","P25G_Network","InactivityTimeout","15"]]
function uci2ini(changes)
	local mmdvmhost_conf = ini_load(MMDVMHOST_CONFFILE)
	local ysfgateway_conf = ini_load(YSFGATEWAY_CONFFILE)
	local p25gateway_conf = ini_load(P25GATEWAY_CONFFILE)
	local mmdvmhost_changed = false

	for _, change in ipairs(changes) do
		local action = change[1]
		local section = change[2]:gsub("_", " ")
		local option = change[3]
		local value = change[4]

		if action == "set" then
			if section == "YSFG Network" then
				ysfgateway_conf["Network"][option] = value
				ini_save(YSFGATEWAY_CONFFILE, ysfgateway_conf)
				log("YSFGateway.ini update - " .. json.stringify(change))
			elseif section == "P25G Network" then
				p25gateway_conf["Network"][option] = value
				ini_save(P25GATEWAY_CONFFILE, p25gateway_conf)
				log("P25GGateway.ini update - " .. json.stringify(change))
			else
				mmdvmhost_conf[section][option] = value
				ini_save(MMDVMHOST_CONFFILE, mmdvmhost_conf)
				log("MMDVM.ini update - " .. json.stringify(change))

				mmdvmhost_changed = true
			end
		end
	end

	return mmdvmhost_changed
end

--- String to time
--@param strtime time string in yyyy-mm-dd HH:MM:ss
function s2t(strtime)
    local year = string.sub(strtime, 1, 4)
    local month = string.sub(strtime, 6, 7)
    local day = string.sub(strtime, 9, 10)
    local hour = string.sub(strtime, 12, 13)
    local minute = string.sub(strtime, 15, 16)
	local second = string.sub(strtime, 18, 19)

	return os.time({day=day, month=month, year=year, hour=hour, min=minute, sec=second})
end

function file_exists(fname)
	-- return fs.stat(fname, 'type') == 'reg'
	return fs.access(fname)
end

function get_bm_list()
	local hostfile = "/etc/mmdvm/BMMasters.txt"
	local file = assert(io.open(hostfile, 'r'), 'Error loading file : ' .. hostfile);
	local data = {};
	for line in file:lines() do
		local tokens = line:split(",")
		table.insert(data, {tokens[1], tokens[2], tokens[4]})
	end

	return data
end

function get_ysf_list()
	local hostfile = "/etc/mmdvm/YSFHosts.txt"
	local file = assert(io.open(hostfile, 'r'), 'Error loading file : ' .. hostfile);
	local data = {};
	for line in file:lines() do
		local tokens = line:split(";")
		table.insert(data, {tokens[1], tokens[2]})
	end

	return data
end

local function _get_p25_list(hostfile)
	local file = assert(io.open(hostfile, 'r'), 'Error loading file : ' .. hostfile);
	local data = {};
	for line in file:lines() do
		if line:trim() ~= "" and line:byte(1) ~= 35 then -- the # char
			local tokens = line:split("%s+", nil, true)
			table.insert(data, {tokens[1], tokens[2]})
		end
	end

	return data
end

function get_p25_list()
	local hostfile = "/etc/mmdvm/P25Hosts.txt"
	local hostfile_private = "/etc/mmdvm/P25Hosts_private.txt"

	local data = _get_p25_list(hostfile)
	for _, d in ipairs(_get_p25_list(hostfile_private)) do
		table.insert(data, {d[1], d[2] .. " - private"})
	end

	return data
end

function log(msg)
	msg = ("mmdvm: %s"):format(msg)
	util.ubus("log", "write", {event = msg})
end

function get_mmdvm_log()
	local logtxt = ""
	local lines = {}
	local logfile = "/var/log/mmdvm/MMDVM-%s.log" % {os.date("%Y-%m-%d")}
	
	if file_exists(logfile) then
		logtxt = util.trim(util.exec("tail -n250 %s | egrep -h \"from|end|watchdog|lost\"" % {logfile}))
		lines = logtxt:split("\n")
	end

	if #lines < 20 then
		logfile = "/var/log/mmdvm/MMDVM-%s.log" % {os.date("%Y-%m-%d", os.time()-24*60*60)}
		if file_exists(logfile) then
			logtxt = logtxt .. "\n" .. util.trim(util.exec("tail -n250 %s | egrep -h \"from|end|watchdog|lost\"" % {logfile}))
			lines = logtxt:split("\n")
		end
	end

	table.sort(lines, function(a,b) return a>b end)

	return lines
	
end

local function get_hearlist(loglines)
	local headlist = {}
	local duration, loss, ber, rssi
	-- local ts1duration, ts1loss, ts1ber, ts1rssi
	-- local ts2duration, ts2loss, ts2ber, ts2rssi
	-- local ysfduration, ysfloss, ysfber, ysfrssi
	-- local p25duration, p25loss, p25ber, p25rssi

	for i = 1, #loglines do
		local logline = loglines[i]
		-- remoing invaild lines
		repeat
			if string.find(logline, "BS_Dwn_Act") or
				string.find(logline, "invalid access") or
				string.find(logline, "received RF header for wrong repeater") or
				string.find(logline, "Error returned") or
				string.find(logline, "unable to decode the network CSBK") or
				string.find(logline, "overflow in the DMR slot RF queue") or
				string.find(logline, "non repeater RF header received") or
				string.find(logline, "Embedded Talker Alias") or 
				string.find(logline, "DMR Talker Alias") or
				string.find(logline, "CSBK Preamble") or
				string.find(logline, "Preamble CSBK")
			then
				break
			end

			local mode = string.sub(logline, 28, (string.find(logline, ",") or 0)-1)

			if string.find(logline, "end of") 
				or string.find(logline, "watchdog has expired")
				or string.find(logline, "ended RF data")
				or string.find(logline, "ended network")
				or string.find(logline, "RF user has timed out")
				or string.find(logline, "transmission lost")
			then
				local linetokens = logline:split(", ")
				local count_tokens = (linetokens and #linetokens) or 0

				if string.find(logline, "RF user has timed out") then
					duration = "-1"
					ber = "-1"
				else
					if count_tokens >= 3 then
						duration = string.trim(string.sub(linetokens[3], 1, string.find(linetokens[3], " ")))
					end
					if count_tokens >= 4 then
						loss = linetokens[4]
					end
				end

				-- if RF-Packet, no LOSS would be reported, so BER is in LOSS position
				if string.find(loss or "", "BER") == 1 then
					ber = string.trim(string.sub(loss, 6, 8))

					loss = "0"
					-- TODO: RSSI
				else
					loss = string.trim(string.sub(loss or "", 1, -14))
					if count_tokens >= 5 then
						ber = string.trim(string.sub(linetokens[5] or "", 6, -2))
						
					end
				end

	--[[]

				if string.find(logline, "ended RF data") or string.find(logline, "ended network") then
					if mode == "DMR Slot 1" then ts1duration = "SMS" 
					elseif mode == "DMR Slot 2" then ts2duration = "SMS" 
					end
				else
					local switch = {
						["DMR Slot 1"] = function()
							ts1duration = duration
							ts1loss = loss
							ts1ber = ber
							ts1rssi = rssi
						end,
						["DMR Slot 2"] = function()
							ts2duration = duration
							ts2loss = loss
							ts2ber = ber
							ts2rssi = rssi
						end,
						["YSF"] = function()
							ysfduration = duration
							ysfloss = loss
							ysfber = ber
							ysfrssi = rssi
						end,
						["P25"] = function()
							p25duration = duration
							p25loss = loss
							p25ber = ber
							p25rssi = rssi
						end
					}
					local f = switch[mode]
					if(f) then f() end
				end
	]]

			end

			local timestamp = string.sub(logline, 4, 22)
			local callsign, target
			if string.find(logline, "from") then
				callsign = string.trim(string.sub(logline, string.find(logline, "from")+5, string.find(logline, "to") - 2))
				target = string.trim(string.sub(logline, string.find(logline, "to") + 3))
				if mode ==  "YSF" then
					target = string.trim(string.sub(target, 14))
				end
			end
			local source = "RF"
			if string.find(logline, "network") then
				source = "Net"
			end

			-- Callsign or ID should be less than 11 chars long, otherwise it could be errorneous
			if callsign and #callsign < 11 then
				table.insert(headlist, 
					{
						timestamp = timestamp, 
						mode = mode, 
						callsign = callsign, 
						target = target, 
						source = source,
						duration = duration,
						loss = tonumber(loss) or 0,
						ber = tonumber(ber) or 0,
						rssi = rssi
					}
				)
			end

		until true -- end repeat
	end -- end loop

	-- table.insert(headlist, 
	-- 	{
	-- 		timestamp = "timestamp", 
	-- 		mode = "mode", 
	-- 		callsign = "callsign", 
	-- 		target = "target", 
	-- 		source = "RF",
	-- 		duration = "duration",
	-- 		loss = tonumber(loss) or 0,
	-- 		ber = tonumber(ber) or 0,
	-- 		rssi = rssi
	-- 	}
	-- )
	return headlist
end

function get_lastheard()
	local lh = {}
	local calls = {}
	local loglines = get_mmdvm_log()
	local headlist = get_hearlist(loglines)

	for i = 1, #headlist, 1 do
		local key = headlist[i].callsign .. "@" .. headlist[i].mode
		
		if calls[key] == nil then
			calls[key] = true
			table.insert(lh, headlist[i])
		end

	end

	return lh
end
