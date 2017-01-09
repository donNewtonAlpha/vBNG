#!/bin/bash

set -x

ip link add link access access.2 type vlan id 2 ingress-qos-map 0:1 1:2 2:3 3:4 4:5 5:6 6:7 7:8 egress-qos-map 1:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7
ip link set access.2 up
ip addr add 20.20.0.1/32 dev access.2
ip route add 20.20.0.2/32 dev access.2 src 20.20.0.1
sh shaper.sh access.3 25mbit 10mbit 200kbit 50kbit 10kbit

ip link add link access access.3 type vlan id 3 ingress-qos-map 0:1 1:2 2:3 3:4 4:5 5:6 6:7 7:8 egress-qos-map 1:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7
ip link set access.3 up
ip addr add 20.20.0.1/32 dev access.3
ip route add 20.20.0.3/32 dev access.3 src 20.20.0.1
sh shaper.sh access.3 25mbit 10mbit 200kbit 50kbit 10kbit

