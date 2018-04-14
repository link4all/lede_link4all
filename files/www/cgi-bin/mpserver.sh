#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_mptcp" = "1" ] ;then
 uci set gargoyle.global.mptcp=1 >/dev/null 2>&1
 uci set shadowsocks-libev.hi.disabled=0
 uci set network.wan1.multipath="on"
 uci set network.wan2.multipath="on"
 uci set network.wan3.multipath="on"
 uci set network.wan4.multipath="on"
 uci set network.wan.multipath="on"
 uci set network.wwan.multipath="on"
  uci set shadowsocks-libev.sss0.server="$FORM_server"
   uci set shadowsocks-libev.sss0.server_port="$FORM_port"
   uci set shadowsocks-libev.sss0.method="$FORM_method"
   uci set shadowsocks-libev.sss0.password="$FORM_passwd"
 if [ "$FORM_m_wan1" = 1 ];then
   uci set network.wan1.multipath=on
 else
   uci set network.wan1.multipath=off
 fi
 if [ "$FORM_m_wan2" = 1 ];then
   uci set network.wan2.multipath=on
 else
   uci set network.wan2.multipath=off
 fi
 if [ "$FORM_m_wan3" = 1 ];then
   uci set network.wan3.multipath=on
 else
   uci set network.wan3.multipath=off
 fi
 if [ "$FORM_m_wan4" = 1 ];then
   uci set network.wan4.multipath=on
 else
   uci set network.wan4.multipath=off
 fi
 if [ "$FORM_m_wan" = 1 ];then
   uci set network.wan.multipath=on
 else
   uci set network.wan.multipath=off
 fi
 if [ "$FORM_m_wwan" = 1 ];then
   uci set network.wwan.multipath=on
 else
   uci set network.wwan.multipath=off
 fi

else
 uci set gargoyle.global.mptcp=0 >/dev/null 2>&1
 uci set shadowsocks-libev.hi.disabled=1
 uci set network.wan1.multipath="off"
 uci set network.wan2.multipath="off"
 uci set network.wan3.multipath="off"
 uci set network.wan4.multipath="off"
 uci set network.wan.multipath="off"
 uci set network.wwan.multipath="off"
 uci set network.$FORM_interface.multipath="on"
 uci set gargoyle.global.master=$FORM_interface

fi

uci commit network
uci commit gargoyle
uci commit shadowsocks-libev
/etc/init.d/shadowsocks-libev restart


echo "{"
echo "\"stat\":\"OK\""
echo "}"
/etc/init.d/network restart
%>

