#!/bin/sh

# 
# Copyright 2019 BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
# 

opkg update
opkg upgrade mmdvm-suite mmdvm-luci-plugin mmdvm-host p25-clients ysf-clients

# TODO: Hostfiles update goes here