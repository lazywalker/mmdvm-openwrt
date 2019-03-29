#!/usr/bin/lua

local mmdvm = require("mmdvm")

mmdvm.init("/Users/mic/Work/radioid/export/DMRIds.dat")
print(mmdvm.get_dmrid_by_callsign("BD7MQB"))