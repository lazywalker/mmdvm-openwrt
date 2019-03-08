#!/bin/sh

# 
# Copyright 2019 BD7MQB (bd7mqb@qq.com)
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
# 

# Full path to DMR ID file
DMRIDFILE=/etc/mmdvm/DMRIds.dat

# Full version
curl 'https://www.radioid.net/static/users.csv' 2>/dev/null | awk -F ',' '{print $1"\t"$2"\t"$3"\t"$4"\t"$6}'  > ${DMRIDFILE}

# Compact version
#wget -O ${DMRIDFILE} http://registry.dstar.su/dmr/DMRIds.php