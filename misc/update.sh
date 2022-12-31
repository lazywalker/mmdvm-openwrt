#!/bin/sh
wget -O YSFHosts.txt http://register.ysfreflector.de/export_csv.php
wget -O FCSRooms.txt http://github.com/g4klx/YSFClients/raw/master/YSFGateway/FCSRooms.txt

wget -O P25Hosts.txt http://github.com/g4klx/P25Clients/raw/master/P25Gateway/P25Hosts.txt

wget -O NXDNHosts.txt http://github.com/g4klx/NXDNClients/raw/master/NXDNGateway/NXDNHosts.txt
wget -O NXDN.csv http://github.com/g4klx/NXDNClients/raw/master/NXDNGateway/NXDN.csv

# XLX live DMR Master Reflector host file.
wget -O XLXHosts.txt http://xlxapi.rlx.lu/api.php?do=GetXLXDMRMaster

# DCS Hosts resolved from xreflector.net DNS, with additional hosts
curl -s "http://xlxapi.rlx.lu/api.php?do=GetReflectorHostname" | grep -a ^DCS > DCS_Hosts.txt

# DPlus Hosts resolved from dstargateway.org DNS, with additional hosts
curl -s "http://xlxapi.rlx.lu/api.php?do=GetReflectorHostname" | grep -a ^XRF > DExtra_Hosts.txt

# DExtra Hosts resolved from the XReflector Directory (http://xrefl.net)
curl -s "http://xlxapi.rlx.lu/api.php?do=GetReflectorHostname" | grep -a ^REF > DPlus_Hosts.txt
