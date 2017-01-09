#!/bin/bash

modprobe ebtables

set -x

ip link set p1p2 up

echo 8 > /sys/class/net/p1p2/device/sriov_numvfs 

ip link set p1p1 up

echo 8 > /sys/class/net/p1p1/device/sriov_numvfs 

sleep 5

#ip link set p1p2_0 up
#ip link set p1p1_0 up

#ip addr add 10.40.1.0/31 dev p1p2_0
#ip addr add 10.10.1.1/31 dev p1p1_0


sysctl -q net.ipv4.ip_forward=1
