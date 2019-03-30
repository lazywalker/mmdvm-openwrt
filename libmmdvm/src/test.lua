#!/usr/bin/env lua

local mmdvm = require("mmdvm")

mmdvm.init("/Users/mic/Work/radioid/export/DMRIds.dat")
rtl = mmdvm.get_dmrid_by_callsign("BD7MQB")

assert(type(rtl) == 'string', 'return value must be string')
assert(rtl == "4607177	BD7MQB	Michael Changzhi Cai	ShenzhenGuangdong	China", 'value unexpected.')

print(rtl)