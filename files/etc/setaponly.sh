#!/bin/sh

if uci get wireless.stamode.mode;then
  if ! ifconfig wlan0 |grep "192.168";then
    uci delete wireless.stamode
    uci commit wireless
    /etc/init.d/network restart
  fi
fi

