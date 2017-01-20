#!/bin/bash
#
# example:  ./vlan-setup.sh access 2 20.20.0.2 20.20.0.1 25mbit
#
#


vlaninf=${1}
shaperate=${2}

if [ -z "$vlaninf" ] || [ -z "$shaperate" ]
then
  echo "Usage $0 <vlan-interface> <southbound-shape-rate>" 1>&2
  exit 1
fi


ip link set ${vlaninf} type vlan ingress-qos-map 0:1 1:2 2:3 3:4 4:5 5:6 6:7 7:8 egress-qos-map 1:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7
# TODO: shaper profile needs to be set from DHCP/RADIUS after ip assignment
sh /usr/local/bin/shaper.sh ${vlaninf} ${shaperate} ${shaperate} 200kbit 50kbit 10kbit

