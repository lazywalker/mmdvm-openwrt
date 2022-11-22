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

Follow the intro at https://github.com/lazywalker/ostar


## License 

This software is licenced under the GPL v2 and is primarily intended for amateur and educational use.

Disclaimer: This software was written as a personal hobby and I am not responsible for products that use this software. Contributions from anyone are welcome.

免责声明：编写此软件纯属个人爱好，我不对使用此软件的产品负责

73, Michael BD7MQB
