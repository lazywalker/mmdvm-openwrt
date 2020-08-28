```
     ____  ______________    ____ 
    / __ \/ ___/_  __/   |  / __ \
   / / / /\__ \ / / / /| | / /_/ /
  / /_/ /___/ // / / ___ |/ _, _/ 
  \____//____//_/ /_/  |_/_/ |_| MMDVM Suite
```
# MMDVM Suite for OpenWrt
This is a feed that let you run MMDVM softwares on OpenWrt

## How to build packages
If you want to run it on your own openwrt v19.07.x linux

### 1. Setup feeds
```bash
cp feeds.conf.default feeds.conf
echo "src-git mmdvm https://github.com/lazywalker/mmdvm-openwrt" >> feeds.conf

./scripts/feeds update -a
./scripts/feeds install -a -pmmdvm

```
Select MMDVM packages with `make menuconfig`, and SAVE.


### 2. Build 
```bash
make package/{mmdvm,mmdvm-host,p25-clients,ysf-clients,nxdn-clients,mmdvm-luci,dapnet-gateway}/{clean,compile} V=s
```

## Build with OSTAR

Follow the intro at https://github.com/lazywalker/openwrt