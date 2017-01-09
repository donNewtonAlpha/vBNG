#!/bin/bash

phy=eth1
vni=5021
vxlanremote=10.20.1.253
gatewayip=20.20.0.1
remotenet=2.2.0.0/16
nexthop=10.20.1.100
bridge=access

third=38
fourth=2

vxlan=vx${vni}

sysctl net.ipv4.ip_forward=1
ip add add ${gatewayip}/32 dev lo

brctl addbr $bridge
ip link add $vxlan mtu 9000 address fe:bb:bb:bb:cc:01 type vxlan id $vni remote $vxlanremote dstport 4789 tos inherit
ip link set $vxlan up
brctl addif $bridge $vxlan
ip link set $bridge up

#tc qdisc del dev $phy ingress
tc qdisc add dev $phy handle ffff: ingress

sh policer.sh $phy 0.0.0.0/0 1
#sh shaper.sh $phy 500mbit

for i in $(seq 2 501)
do
   vif=${bridge}.${i}
   ip link add link $bridge $vif type vlan id $i ingress-qos-map 0:1 1:2 2:3 3:4 4:5 5:6 6:7 7:8 egress-qos-map 1:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7
   ip link set $vif up
   ip add add ${gatewayip}/32 dev $vif

   if  [ $fourth -gt 255 ]
   then
      fourth=0
      third=$((third + 1))
   fi

   echo $vif
   ip=20.20.${third}.${fourth}
   fourth=$((fourth+1))
   echo $ip
   ip route add $ip/32 dev $vif src $gatewayip

   #sh policer.sh $phy $ip $i
   sh shaper.sh $vif 1mbit

done

ip route add $remotenet via $nexthop


###
### northbound set mark from vlan prio, then set dscp class from mark
###
ebtables -A INPUT --protocol 802_1Q --vlan-prio 7 -j mark --set-mark 7 --mark-target ACCEPT
#ebtables -A INPUT --protocol 802_1Q --vlan-prio 6 -j mark --set-mark 6 --mark-target ACCEPT
#ebtables -A INPUT --protocol 802_1Q --vlan-prio 5 -j mark --set-mark 5 --mark-target ACCEPT
#ebtables -A INPUT --protocol 802_1Q --vlan-prio 4 -j mark --set-mark 4 --mark-target ACCEPT
ebtables -A INPUT --protocol 802_1Q --vlan-prio 3 -j mark --set-mark 3 --mark-target ACCEPT
#ebtables -A INPUT --protocol 802_1Q --vlan-prio 2 -j mark --set-mark 2 --mark-target ACCEPT
#ebtables -A INPUT --protocol 802_1Q --vlan-prio 1 -j mark --set-mark 1 --mark-target ACCEPT
#ebtables -A INPUT --protocol 802_1Q --vlan-prio 0 -j mark --set-mark 0 --mark-target ACCEPT

iptables -t mangle -A POSTROUTING  -m mark --mark 7 -j DSCP --set-dscp-class EF 
#iptables -t mangle -A POSTROUTING  -m mark --mark 6 -j DSCP --set-dscp-class AF11
#iptables -t mangle -A POSTROUTING  -m mark --mark 5 -j DSCP --set-dscp-class AF12
#iptables -t mangle -A POSTROUTING  -m mark --mark 4 -j DSCP --set-dscp-class AF13
iptables -t mangle -A POSTROUTING  -m mark --mark 3 -j DSCP --set-dscp-class AF21
#iptables -t mangle -A POSTROUTING  -m mark --mark 2 -j DSCP --set-dscp-class AF22
#iptables -t mangle -A POSTROUTING  -m mark --mark 1 -j DSCP --set-dscp-class AF23
#iptables -t mangle -A POSTROUTING  -m mark --mark 0 -j DSCP --set-dscp-class BE

##
## southbound set mark from dscp class, then vlan prio from mark (see above egress-qos-map)
##

iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class EF -j CLASSIFY --set-class 1:7
iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class EF -j MARK --set-mark 0x7
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF11 -j CLASSIFY --set-class 0:6
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF12 -j CLASSIFY --set-class 0:5
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF13 -j CLASSIFY --set-class 0:4
iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF21 -j CLASSIFY --set-class 1:3
iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF21 -j MARK --set-mark 0x3
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF22 -j CLASSIFY --set-class 0:2
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF23 -j CLASSIFY --set-class 0:1
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class BE -j CLASSIFY --set-class 1:13
