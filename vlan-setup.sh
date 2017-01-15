#!/bin/bash
#
# example:  ./vlan-setup.sh access 2 20.20.0.2 20.20.0.1 25mbit
#
#


phy=${1}
vlanid=${2}
shaperate=${3}

if [ -z "$phy" ] || [ -z "$vlanid" ] || [ -z "$shaperate" ]
then
  echo "Usage $0 <phy-data-plane> <customer-vlan-id> <southbound-shape-rate>" 1>&2
  exit 1
fi

set -x

vlaninf=${phy}.${vlanid}


ip link set ${vlaninf} type vlan ingress-qos-map 0:1 1:2 2:3 3:4 4:5 5:6 6:7 7:8 egress-qos-map 1:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7
sh /usr/local/bin/shaper.sh ${vlaninf} ${shaperate} ${shaperate} 200kbit 50kbit 10kbit

