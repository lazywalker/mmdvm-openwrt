#!/bin/sh /etc/rc.common
# 
# Copyright 2019 BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
# 
# The control script of mmdvm services
#

SERVICE_WRITE_PID=0
SERVICE_DAEMONIZE=0
EXTRA_COMMANDS="status update"                                                                                        
EXTRA_HELP="	status	Display status of mmdvm services
	update	Upgrade the mmdvm suite to lastest version" 

help() {
	cat <<EOF
Syntax: $initscript [command]

* This is the control script of mmdvm services (mmdvmhost, p25gateway, p25parrot, ysfgateway, ysfparrot).
* For pkg update, run 'mmdvmctl update'

Available commands:
	start	Start the mmdvm services
	stop	Stop the mmdvm services
	restart	Restart the mmdvm services
	enable	Enable mmdvm services autostart
	disable	Disable mmdvm services autostart
$EXTRA_HELP
EOF
}

_command() {
    /etc/init.d/mmdvmhost $1
    /etc/init.d/p25gateway $1
    /etc/init.d/p25parrot $1
    /etc/init.d/ysfgateway $1
    /etc/init.d/ysfparrot $1
    /etc/init.d/dmrid $1
}

start() {
    _command start
}

stop() {
    _command stop
}

enable() {
    _command enable
}

disable() {
    _command disable
}

status() {
    _command status
}

update() {
    opkg update
    opkg upgrade mmdvm libmmdvm mmdvm-luci mmdvm-luci-i18n-zh-cn mmdvm-host p25-clients ysf-clients
}
