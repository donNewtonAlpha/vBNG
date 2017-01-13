#!/bin/bash
#
# example:  ./vbng-setup-vxlan2.sh 5002 10.50.1.1 eth2 2500mbit
#
#


vni=${1}
vxlanlocal=${2}
vxlanremote=${3}
uplinkphy=${4}
policerate=${5}

if [ -z "$vni" ] || [ -z "$vxlanlocal" ] || [ -z "$vxlanremote" ] || [ -z "$uplinkphy" ] || [ -z "$policerate" ]
then
  echo "Usage $0 <vxlan-vni> <vxlan-local-ip> <vxlan-remote-ip> <uplink-phy> <southbound-police-rate>" 1>&2
  exit 1
fi


set -x

bridge=access
vxlan=vx${vni}

brctl addbr $bridge
ip link add $vxlan type vxlan id $vni local $vxlanlocal remote $vxlanremote dstport 4789 tos inherit
ip link set ${vxlan} mtu 9216
ip link set $vxlan up
brctl addif $bridge $vxlan
ip link set $bridge up

tc qdisc add dev $uplinkphy handle ffff: ingress
tc filter add dev $uplinkphy parent ffff: protocol ip prio 4 u32 \
   match ip tos 0x00 0xfc \
   police rate $policerate burst 1mbit \
   drop flowid 0:3


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

iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class EF -j CLASSIFY --set-class 1:7
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class EF -j MARK --set-mark 0x7
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF11 -j CLASSIFY --set-class 1:6
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF11 -j MARK --set-mark 0x6
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF12 -j CLASSIFY --set-class 1:5
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF12 -j MARK --set-mark 0x5
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF13 -j CLASSIFY --set-class 1:4
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF13 -j MARK --set-mark 0x4
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF21 -j CLASSIFY --set-class 1:3
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF21 -j MARK --set-mark 0x3
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF22 -j CLASSIFY --set-class 1:2
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF22 -j MARK --set-mark 0x2
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF23 -j CLASSIFY --set-class 1:1
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF23 -j MARK --set-mark 0x1

