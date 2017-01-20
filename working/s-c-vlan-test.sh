#!/bin/bash

gatewayip=20.20.0.1

third=0
fourth=2

#set -x

sysctl -q net.ipv4.ip_forward=1

ip link set eth1 mtu 9216
ip link set eth1 up 
ip link set eth2 mtu 9216
ip link set eth2 up 

brctl addbr access
brctl addif access eth1
ip link set access up


for i in $(seq 2 11)
do
   ip link add link access access.${i} type vlan proto 802.1ad id ${i}
   #ip link add link access access.${i} type vlan id ${i}
   ip link set access.${i} up

  for j in $(seq 2 51)
  do
    ip link add link access.${i} access.${i}.${j} type vlan id $j ingress-qos-map 0:1 0:2 2:3 3:4 4:5 5:6 6:7 7:8 egress-qos-map 0:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7
    ip link set access.${i}.${j} up
    ip add add ${gatewayip}/32 dev access.${i}.${j}

    if  [ $fourth -gt 255 ]
    then
      fourth=0
      third=$((third + 1))
    fi

    sh /usr/local/bin/shaper.sh access.${i}.${j} 10mbit 10mbit 200kbit 50kbit 10kbit

    ip=20.20.${third}.${fourth}
    fourth=$((fourth+1))
    echo $ip

    ip route add $ip/32 dev access.${i}.${j} src $gatewayip
  done

done

###
### northbound set mark from vlan prio, then set dscp class from mark
###
ebtables -A INPUT --protocol 802_1Q --vlan-prio 7 -j mark --set-mark 7 --mark-target ACCEPT
ebtables -A INPUT --protocol 802_1Q --vlan-prio 6 -j mark --set-mark 6 --mark-target ACCEPT
ebtables -A INPUT --protocol 802_1Q --vlan-prio 5 -j mark --set-mark 5 --mark-target ACCEPT
ebtables -A INPUT --protocol 802_1Q --vlan-prio 4 -j mark --set-mark 4 --mark-target ACCEPT
ebtables -A INPUT --protocol 802_1Q --vlan-prio 3 -j mark --set-mark 3 --mark-target ACCEPT
ebtables -A INPUT --protocol 802_1Q --vlan-prio 2 -j mark --set-mark 2 --mark-target ACCEPT
ebtables -A INPUT --protocol 802_1Q --vlan-prio 1 -j mark --set-mark 1 --mark-target ACCEPT

iptables -t mangle -A POSTROUTING  -m mark --mark 7 -j DSCP --set-dscp-class EF
iptables -t mangle -A POSTROUTING  -m mark --mark 6 -j DSCP --set-dscp-class AF11
iptables -t mangle -A POSTROUTING  -m mark --mark 5 -j DSCP --set-dscp-class AF12
iptables -t mangle -A POSTROUTING  -m mark --mark 4 -j DSCP --set-dscp-class AF13
iptables -t mangle -A POSTROUTING  -m mark --mark 3 -j DSCP --set-dscp-class AF21
iptables -t mangle -A POSTROUTING  -m mark --mark 2 -j DSCP --set-dscp-class AF22
iptables -t mangle -A POSTROUTING  -m mark --mark 1 -j DSCP --set-dscp-class AF23


##
## southbound set mark from dscp class, then vlan prio from mark (see above egress-qos-map)
##

iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class EF -j CLASSIFY --set-class 0:7
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class EF -j MARK --set-mark 0x7
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF11 -j CLASSIFY --set-class 0:6
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF11 -j MARK --set-mark 0x6
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF12 -j CLASSIFY --set-class 0:5
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF12 -j MARK --set-mark 0x5
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF13 -j CLASSIFY --set-class 0:4
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF13 -j MARK --set-mark 0x4
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF21 -j CLASSIFY --set-class 0:3
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF21 -j MARK --set-mark 0x3
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF22 -j CLASSIFY --set-class 0:2
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF22 -j MARK --set-mark 0x2
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF23 -j CLASSIFY --set-class 0:1
iptables -t mangle -A FORWARD -i eth2 -m dscp --dscp-class AF23 -j MARK --set-mark 0x1

