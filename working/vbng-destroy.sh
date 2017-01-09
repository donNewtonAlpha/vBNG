#!/bin/bash
#
# example:  ./vbng-destroy.sh eth1 10.20.1.22/24 5002 10.20.1.1 20.20.0.1 2.2.0.0/16 10.20.1.100
#
#

phy=$1
phyipmask=$2
vni=$3
vxlanremote=$4
gatewayip=$5
remotenet=$6
nexthop=$7
policerate=$8

if [ -z "$phy" ] || [ -z "$phyipmask" ] || [ -z "$vni" ] || [ -z "$vxlanremote" ] || [ -z "$gatewayip" ] || [ -z "$remotenet" ] || [ -z "$nexthop" ] || [ -z "$policerate" ]
then
  echo "Usage $0 <phy-data-plane> <phy-ip/mask> <vxlan-vni> <vxlan-remote-ip> <customer-gateway-ip> <northbound-route> <northbound-route-nexthop-ip> <southbound-police-rate>" 1>&2
  exit 1
fi

bridge=access
vxlan=vx${vni}

ip route del $remotenet via $nexthop
ip link set ${phy} down
ip addr flush dev ${phy}
ip addr del ${gatewayip}/32 dev lo

tc qdisc del dev $phy root
tc qdisc del dev $phy ingress

iptables -F -t mangle
ebtables -F
ip link set $bridge down
brctl delbr $bridge
ip link del $vxlan

