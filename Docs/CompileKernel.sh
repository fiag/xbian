#!/bin/bash
#
#Copyright 2012 CurlyMo, Erwin Bovendeur <development@xbian.org>
#Aron Robert Szabo <aron@reon.hu>
#Frank Buss <fb@frank-buss.de>
#
#This file is part of XBian - XBMC on the Raspberry Pi.
#
#XBian is free software: you can redistribute it and/or modify it under the 
#terms of the GNU General Public License as published by the Free Software 
#Foundation, either version 3 of the License, or (at your option) any later 
#version.
#
#XBian is distributed in the hope that it will be useful, but WITHOUT ANY 
#WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
#FOR A PARTICULAR PURPOSE. See the GNU General Public License for more 
#details.
#
#You should have received a copy of the GNU General Public License along 
#with XBian. If not, see <http://www.gnu.org/licenses/>
#

#Download compilation tools from the official raspberry pi github
cd /usr/src
sudo git clone --depth 5 https://github.com/raspberrypi/tools.git
cd tools
sudo ln -s /usr/src/tools/arm-bcm2708/arm-bcm2708-linux-gnueabi/bin/arm-bcm2708-linux-gnueabi-gcc /usr/bin/arm-bcm2708-linux-gnueabi-gcc

#Download the official kernel from the raspberry pi github
sudo mkdir /opt/raspberry
cd /opt/raspberry
sudo git clone --depth 5 git://github.com/raspberrypi/linux.git
cd linux

#Download the used config from the XBian github
sudo wget https://raw.github.com/Koenkk/xbian/master/Patches/kernel/.config

#Symlink the lirc drivers to get the patch working
sudo ln -s /opt/raspberry/linux/drivers/staging/media/lirc /opt/raspberry/linux/drivers/staging/lirc
sudo wget https://raw.github.com/Koenkk/xbian/master/Patches/kernel/Kernel.lirc_rpi-0.2+lirc_xbox.patch
sudo patch -p1 < Kernel.lirc_rpi-0.2+lirc_xbox.patch

#Download latest lirc_rpi version
sudo wget https://github.com/ar0n/linux/blob/rpi-patches/drivers/staging/lirc/lirc_rpi.c
sudo mv lirc_rpi.c drivers/staging/lirc
sudo cat drivers/staging/lirc_rpi.c | sed -e 's/lirc_rpi/lirc_rp1/g' > drivers/staging/lirc_rp1.c

#Stop XBMC to increase compilation speed
sudo kill -9 $(pgrep xbmc)

#Make steps with custom commands not supported by the official config
sudo make CROSS_COMPILE=/usr/bin/ CONFIG_LIRC_STAGING=y CONFIG_LIRC_RPI=m CONFIG_I2C_DEV=m CONFIG_LIRC_RP1=m CONFIG_LIRC_XBOX=m
sudo make modules CROSS_COMPILE=/usr/bin/ CONFIG_LIRC_STAGING=y CONFIG_LIRC_RPI=m CONFIG_I2C_DEV=m CONFIG_LIRC_RP1=m CONFIG_LIRC_XBOX=m
sudo make modules_install CROSS_COMPILE=/usr/bin/ CONFIG_LIRC_STAGING=y CONFIG_LIRC_RPI=m CONFIG_I2C_DEV=m CONFIG_LIRC_RP1=m CONFIG_LIRC_XBOX=m INSTALL_MOD_PATH=/

#Implement the new kernel
cp arch/arm/boot/Image /boot/kernel.img

#Reboot
reboot
