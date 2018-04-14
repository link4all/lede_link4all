#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/netstatus.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Main page</title>
<script type="text/javascript" src="/jjs/jquery.js"></script>
<link rel="stylesheet" type="text/css" href="css/form.css" />
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript">
function clear_4g(){
$.ajax({
       url: "/cgi-bin/clear4g.sh",
       type: "POST",
       cache: false,
       //data: form,
       processData:false,
       contentType:false,
       success: function(json) {
         $("#used_byte").html("0");
         }
       });
}
    </script>

</head>
<body>
<div class="current"><%= $location%></div>
<div class="wrap-main" style="position: relative;min-height: 100%">
		<div class="wrap">
				<div class="title"><%= $wan_status%></div>
				<div class="wrap-table">
						<table border="0" cellspacing="0" cellpadding="0" >
									<tr>
												<td ><%= $wan_if%></td>
												<td><%= $ip_addr%></td>
												<td ><%= $run_time%></td>
									</tr>
									<tr>
												<td >WAN</td>
												<td><%= `ubus call network.interface.wan status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "` %></td>
												<td><%= `ubus call network.interface.wan status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "` %></td>
										</tr>
                    <%
                    if [ "`ifconfig apcli0 |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                    echo "<tr>"
										echo "<td >WWAN</td>"
										echo "<td>"
                    ubus call network.interface.wwan status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td><td>"
                    ubus call network.interface.wwan status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td></tr>"
                    fi
                    %>
                    <%
                    if [ "`ubus call network.interface.4g status |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                    echo "<tr>"
										echo "<td >4G</td>"
										echo "<td>"
                    ubus call network.interface.4g status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td><td>"
                    ubus call network.interface.4g status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td></tr>"
                    fi
                    %>
                    <%
                    if [ "`ifconfig pptp-pptp |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                    echo "<tr>"
                    echo "<td >PPTP</td>"
                    echo "<td>"
                    ubus call network.interface.pptp status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td><td>"
                    ubus call network.interface.pptp status |grep "uptime" |cut -d: -f2 |tr -d "\"\, "
                    echo "</td></tr>"
                    fi
                    %>
                    <%
                    if [ "`ifconfig tun0 |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
                    echo "<tr>"
                    echo "<td >TUN0</td>"
                    echo "<td>"
                    ifconfig tun0 |grep inet |cut -d: -f2 |cut -d" " -f1
                    echo "</td><td>"
                    echo "unkown"
                    echo "</td></tr>"
                    fi
                    %>
								</table>
					<div class="title"><%= $modem_info%></div>
						<div class="wrap-table">
						<table border="0" cellspacing="0" cellpadding="0" >
              <%
              get_op(){
                s1=`uci get display.$1.m_operator`
                case $s1 in
                  "ct")
                   echo "China Net"
                   ;;
                  "cu")
                   echo "China Unicom"
                   ;;
                  "cm")
                   echo "China Mobile"
                   ;;
                   *)
                   echo "Sim not insert"
                esac
              }
              sim1=`get_op wan1`
              sim2=`get_op wan2`
              sim3=`get_op wan3`
              sim4=`get_op wan4`
              sig1=$((`uci get display.wan1.m_rssi` * 20))%
              sig2=$((`uci get display.wan2.m_rssi` * 20))%
              sig3=$((`uci get display.wan3.m_rssi` * 20))%
              sig4=$((`uci get display.wan4.m_rssi` * 20))%
              get_ip(){
              if [ "`ubus call network.interface.$1 status |grep -E  '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`" ];then
              echo `ubus call network.interface.$1 status |grep "\"address\":" |cut -d: -f2 |tr -d "\"\, "`
              else
              echo "Not connect!"
              fi
              }
              ip1=`get_ip wan1`
              ip2=`get_ip wan2`
              ip3=`get_ip wan3`
              ip4=`get_ip wan4`
              used(){
                total=$((`uci get display.$1.rx1_b` + `uci get display.$1.tx1_b` ))
                if [ $total -ge 1000000 ];then
                 rx=`awk -v x=$total  'BEGIN{printf "%.1fMB",x/1000000}'`
                 echo $rx
                elif [ $total -ge 1000 ]; then
                 rx=`awk -v x=$total  'BEGIN{printf "%dKB",x/1000}'`
                 echo $rx
                else
                 rx=`awk -v x=$total   'BEGIN{printf "%dKB",x/1000}'`
                 echo $rx
                fi
              }
                 used1=`used wan1`
                 used2=`used wan2`
                 used3=`used wan3`
                 used4=`used wan4`
              %>
              <tr>
                  <td  width="20%" ></td>
                  <td  width="10%" >SIM</td>
                  <td  width="10%" ><%= $sig%></td>
                  <td  width="20%" >IP</td>
                  <td width="10%">Used</td>
              </tr>
										<tr>
												<td  width="20%" >4G Modem 1</td>
                        <td  width="10%" ><%= $sim1 %></td>
                        <td  width="10%" ><%= $sig1 %></td>
                        <td  width="20%" ><%= $ip1 %></td>
                        <td width="10%"><%= $used1 %></td>
										</tr>
										<tr>
												<td >4G Modem 2</td>
                        <td  width="10%" ><%= $sim2 %></td>
                        <td  width="10%" ><%= $sig2 %></td>
                        <td  width="20%" ><%= $ip2 %></td>
                        <td width="10%"><%= $used2 %></td>
										</tr>
										<tr>
												<td >4G Modem 3</td>
                        <td  width="10%" ><%= $sim3 %></td>
                        <td  width="10%" ><%= $sig3 %></td>
                        <td  width="20%" ><%= $ip3 %></td>
                      <td width="10%"><%= $used3 %></td>
                    </tr>
										<tr>
												<td >4G Modem 4</td>
                        <td  width="10%" ><%= $sim4 %></td>
                        <td  width="10%" ><%= $sig4 %></td>
                        <td  width="20%" ><%= $ip4 %></td>
                      <td width="10%"><%= $used4 %></td>
                    </tr>
										<!-- <tr>
												<td ><%= $used_byte%></td>
												<td id="used_byte"  colspan="2"><%= `uci get 4g.modem.4g_byte 2>/dev/null` %></td>
                        </tr> -->
							</table>
              <br />
              <!-- <div class="btn-wrap">
              <div class="save-btn fr"><a href="javascript:clear_4g()"><%= $clear%></a></div>
            </div> -->
						</div>
				</div>
		</div>
</div>
</body>
</html>

