#!/bin/bash
#
# example:  ./vbng-setup2.sh eth1 10.30.2.2/24 10.30.2.1 10.50.1.2 5002 10.50.1.1 20.20.0.1 eth2 10.30.1.2/24 10.30.1.1 2500mbit
#
#

#set -x


phy=${1}
phyipmask=${2}
phyipremote=${3}
loopip=${4}
vni=${5}
vxlanremote=${6}
gatewayip=${7}
uplinkphy=${8}
uplinkipmask=${9}
nexthop=${10}
policerate=${11}

if [ -z "$phy" ] || [ -z "$phyipmask" ] || [ -z "$phyipremote" ] || [ -z "$loopip" ] || [ -z "$vni" ] || [ -z "$vxlanremote" ] || [ -z "$gatewayip" ] || [ -z "$uplinkphy" ] || [ -z "$uplinkipmask" ] || [ -z "$nexthop" ] || [ -z "$policerate" ]
then
  echo "Usage $0 <phy-data-plane> <phy-data-plane-ip/mask> <phy-data-plane-downstream-hop> <loopback-ip> <vxlan-vni> <vxlan-remote-ip> <customer-gateway-ip> <uplink-phy> <uplink-ip/mask> <uplink-nexthop-ip> <southbound-police-rate>" 1>&2
  exit 1
fi

OspfTemplateFile="/root/ospfd-template.conf"
BgpTemplateFile="/root/bgpd-template.conf"
ZebraTemplateFile="/root/zebra-template.conf"

bridge=access
vxlan=vx${vni}

ifconfig ${phy} txqueuelen 4096
ip link set ${phy} mtu 9000
ip addr add ${phyipmask} dev ${phy}
ip link set ${phy} up

ip addr add ${loopip}/32 dev lo
ip addr add ${gatewayip}/32 dev lo

brctl addbr $bridge
ip link add $vxlan type vxlan id $vni local $loopip remote $vxlanremote dstport 4789 tos inherit
ip link set ${vxlan} mtu 9000
ip link set $vxlan up
brctl addif $bridge $vxlan
ip link set $bridge up

ifconfig ${uplinkphy} txqueuelen 4096 
ip link set ${uplinkphy} mtu 9000
ip addr add ${uplinkipmask} dev ${uplinkphy}
ip link set ${uplinkphy} up

phyip=$(echo $phyipmask | cut -d'/' -f1)
uplinkip=$(echo $uplinkipmask | cut -d'/' -f1)

cat $OspfTemplateFile | sed s/%OSPF-ROUTER-ID%/${uplinkip}/g >> /etc/quagga/ospfd.conf
cat $BgpTemplateFile | sed s/%BGP-ROUTER-ID%/${uplinkip}/g | sed s/%BGP-NORTH-NEIGHBOR%/${nexthop}/g >> /etc/quagga/bgpd.conf
cat $ZebraTemplateFile | sed s/%VNI%/${vni}/g >> /etc/quagga/zebra.conf

service quagga restart

tc qdisc add dev $uplinkphy handle ffff: ingress
tc filter add dev $uplinkphy parent ffff: protocol ip prio 4 u32 \
   match ip tos 0x00 0xfc \
   police rate $policerate burst 1mbit \
   drop flowid $uid:3


#ip route add $remotenet via $nexthop dev ${uplinkphy}
ip route add ${vxlanremote}/32 via ${phyipremote}


sysctl -q net.ipv4.ip_forward=1


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

iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class EF -j CLASSIFY --set-class 1:7
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class EF -j MARK --set-mark 0x7
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF11 -j CLASSIFY --set-class 0:6
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF12 -j CLASSIFY --set-class 0:5
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF13 -j CLASSIFY --set-class 0:4
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF21 -j CLASSIFY --set-class 1:3
iptables -t mangle -A FORWARD -i $uplinkphy -m dscp --dscp-class AF21 -j MARK --set-mark 0x3
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF22 -j CLASSIFY --set-class 0:2
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class AF23 -j CLASSIFY --set-class 0:1
#iptables -t mangle -A FORWARD -i $phy -m dscp --dscp-class BE -j CLASSIFY --set-class 1:13
