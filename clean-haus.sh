#!/bin/bash

set -x

phy=eth1
uplinkphy=eth2

vni=5002
bridge=access

vxlan=vx${vni}

tc qdisc del dev $uplinkphy root
tc qdisc del dev $uplinkphy ingress

iptables -F -t mangle
ebtables -F

ip link set $bridge down
brctl delbr $bridge
ip link del $vxlan

ip addr flush $phy
ip addr flush $uplinkphy

ip addr del 20.20.0.1/32 dev lo
ip addr del 10.50.1.2/32 dev lo
