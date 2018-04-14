#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_mptcp" = "1" ] ;then
 uci set gargoyle.global.mptcp=1 >/dev/null 2>&1
 uci set shadowsocks-libev.hi.disabled=0
 uci commit gargoyle
 uci commit shadowsocks-libev
 /etc/init.d/shadowsocks-libev restart
else
 uci set gargoyle.global.mptcp=0 >/dev/null 2>&1
 uci set shadowsocks-libev.hi.disabled=1
 uci commit gargoyle
 uci commit shadowsocks-libev
 /etc/init.d/shadowsocks-libev restart
fi

if [ "$FORM_w1" -eq 1 ] ;then
uci get network.wan1.multipath` = "on" >/dev/null 2>&1
uci commit network
else
uci get network.wan1.multipath` = "off" >/dev/null 2>&1
uci commit network
fi

if [ "$FORM_w2" -eq 1 ] ;then
uci get network.wan2.multipath` = "on" >/dev/null 2>&1
uci commit network
else
uci get network.wan2.multipath` = "off" >/dev/null 2>&1
uci commit network
fi

if [ "$FORM_w3" -eq 1 ] ;then
uci get network.wan3.multipath` = "on" >/dev/null 2>&1
uci commit network
else
uci get network.wan3.multipath` = "off" >/dev/null 2>&1
uci commit network
fi

if [ "$FORM_w4" -eq 1 ] ;then
uci get network.wan4.multipath` = "on" >/dev/null 2>&1
uci commit network
else
uci get network.wan4.multipath` = "off" >/dev/null 2>&1
uci commit network
fi

echo "{"
echo "\"success\":\"ok\""
echo "}"
/etc/init.d/network restart
%>
