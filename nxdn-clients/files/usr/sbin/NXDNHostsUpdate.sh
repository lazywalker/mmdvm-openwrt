#! /bin/sh

# 
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
# 

wget -O /etc/mmdvm/NXDNHosts.txt -q "http://github.com/g4klx/NXDNClients/raw/master/NXDNGateway/NXDNHosts.txt"
wget -O /etc/mmdvm/NXDN.csv -q "http://github.com/g4klx/NXDNClients/raw/master/NXDNGateway/NXDN.csv"

# TODO: a way to fetch formated NXDN.csv from radioid.net