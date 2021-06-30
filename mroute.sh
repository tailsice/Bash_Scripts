#!/bin/bash

EXT1_TYPE="static"
EXT1_IF="eth0"
EXT1_IP="118.163.4.178"
EXT1_GW="118.163.4.254"
EXT1_WEIGHT="1"

EXT2_TYPE="static"
EXT2_IF="eth1"
EXT2_IP="140.131.115.201"
EXT2_GW="140.131.114.254"
EXT2_WEIGHT="1"


[ "$EXT1_TYPE" = "ppp" ] && PPP="1"
[ "$EXT2_TYPE" = "ppp" ] && PPP="1"

if [ "$PPP" = "1" ]; then
	if ! ip address ls | grep ppp > /dev/null; then
		echo "ppp0 is down!"
		exit 1
	fi
fi

for i in 100 200 ; do
	if [ "$i" = "100" ]; then
		TYPE="$EXT1_TYPE"
		IP="$EXT1_IP"
		GW="$EXT1_GW"
	else
		TYPE="$EXT2_TYPE"
		IP="$EXT2_IP"
		GW="$EXT2_GW"
	fi
	
	if [ "$TYPE" = "static" ]; then
		ip rule del from $IP table $i 2>/dev/null
		ip route del table $i 2>/dev/null
		ip route replace default via $GW table $i
		ip rule add from $IP table $i
		[ "$i" = "100" ] && EXT1_GW_S="$GW"
		[ "$i" = "200" ] && EXT2_GW_S="$GW"
	else
                ppp0_gw=`ip route ls | awk '/ppp0.*src/ {print $1}'`
                ppp0_ip=`ip route ls | awk '/ppp0.*src/ {print $9}'`

                ip rule del from $ppp0_ip table $i 2>/dev/null
                ip route del table $i 2>/dev/null
		ip route replace default via $ppp0_gw table $i
		ip rule add from $ppp0_ip table $i
		[ "$i" = "100" ] && EXT1_GW_S="$ppp0_gw"
		[ "$i" = "200" ] && EXT2_GW_S="$ppp0_gw"
	fi
done


ip route replace default \
   nexthop via $EXT1_GW_S dev $EXT1_IF weight $EXT1_WEIGHT \
   nexthop via $EXT2_GW_S dev $EXT2_IF weight $EXT2_WEIGHT

ip route flush cache

echo 
echo "Multiple Routing set OK!"
echo 
