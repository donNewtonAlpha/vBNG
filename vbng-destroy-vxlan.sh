#!/bin/bash
#
# example:  ./vbng-destroy-vxlan.sh 5002 eth2
#
#


vni=${1}
uplinkphy=${2}

if [ -z "$vni" ] || [ -z "$uplinkphy" ]
then
  echo "Usage $0 <vxlan-vni> <uplink-phy>" 1>&2
  exit 1
fi


set -x

bridge=access
vxlan=vx${vni}

brctl delif $bridge $vxlan
ip link del $vxlan 

tc qdisc del dev $uplinkphy root
tc qdisc del dev $uplinkphy ingress

iptables -F -t mangle
ebtables -F



