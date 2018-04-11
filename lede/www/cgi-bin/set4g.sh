#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_dialmode" = "pppd" ];then
uci set network.wan$FORM_modemid.proto='3g'
uci set network.wan$FORM_modemid.service="umts"
uci del network.wan$FORM_modemid.ifname
uci set network.wan$FORM_modemid.device="$FORM_device"
uci set network.wan$FORM_modemid.apn="$FORM_apn"
uci set network.wan$FORM_modemid.pincode="$FORM_pincode"
uci set network.wan$FORM_modemid.username="$FORM_username"
uci set network.wan$FORM_modemid.dialnumber="$FORM_dialnumber"
uci set network.wan$FORM_modemid.password="$FORM_password"
uci commit network
uci set config4g.@4G[$(($FORM_modemid -1))].enable="0"
uci commit config4g
uci set 4g.modem$FORM_modemid.device=$FORM_at
uci commit 4g
killall quectel-CM
/etc/init.d/config4g stop
/etc/init.d/network restart
else
  uci set network.wan$FORM_modemid.proto='dhcp'
  uci del network.wan$FORM_modemid.service
  uci set network.wan$FORM_modemid.ifname="eth1"
  uci del network.wan$FORM_modemid.device
  uci del network.wan$FORM_modemid.apn
  uci del network.wan$FORM_modemid.pincode
  uci del network.wan$FORM_modemid.username
  uci del network.wan$FORM_modemid.dialnumber
  uci del network.wan$FORM_modemid.password
  uci commit network
  uci set config4g.@4G[$(($FORM_modemid -1))].enable="1"
  uci set config4g.@4G[$(($FORM_modemid -1))].apn="$FORM_apn"
  uci set config4g.@4G[$(($FORM_modemid -1))].pincode="$FORM_pincode"
  uci set config4g.@4G[$(($FORM_modemid -1))].user="$FORM_username"
  uci set config4g.@4G[$(($FORM_modemid -1))].password="$FORM_password"
  uci commit config4g
  uci set 4g.modem$FORM_modemid.device=$FORM_at
  uci commit 4g
/etc/init.d/config4g restart
  /etc/init.d/network restart
fi
i=0
i=0
while [ $i -lt 8 ]
do
[ `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` ] || i=$(($i+1))
ipaddr=`ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "`
#echo $ipaddr
[ `ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` ] &&  break
done
echo "{"
echo "\"ipaddr\":\"$ipaddr\""
echo "}"

%>
