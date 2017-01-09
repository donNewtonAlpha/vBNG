#!/bin/bash
#
# example:  ./customer-setup.sh access 2 20.20.0.2 20.20.0.1 25mbit
#
#


phy=${1}
vlanid=${2}
custip=${3}
gatewayip=${4}
shaperate=${5}

if [ -z "$phy" ] || [ -z "$vlanid" ] || [ -z "$custip" ] || [ -z "$gatewayip" ] || [ -z "$shaperate" ]
then
  echo "Usage $0 <phy-data-plane> <customer-vlan-id> <customer-ip> <customer-gateway-ip> <southbound-shape-rate>" 1>&2
  exit 1
fi

set -x

vlaninf=${phy}.${vlanid}


## TODO: much of this is decidede by radius/dhcp and their purchased profile
ip link add link access ${vlaninf} type vlan id ${vlanid} ingress-qos-map 0:1 1:2 2:3 3:4 4:5 5:6 6:7 7:8 egress-qos-map 1:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7
ip link set ${vlaninf} up
ip addr add ${gatewayip}/32 dev ${vlaninf}
ip route add ${custip}/32 dev ${vlaninf} src ${gatewayip}
sh shaper.sh ${vlaninf} ${shaperate} ${shaperate} 200kbit 50kbit 10kbit

