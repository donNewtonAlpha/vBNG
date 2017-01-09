#!/bin/bash

modprobe ebtables

set -x

ip link set p1p2 up
echo 8 > /sys/class/net/p1p2/device/sriov_numvfs 

ip link set p1p1 up
ip addr add 10.10.1.1/31 dev p1p1

ip link add loop-south type dummy
ip link set loop-south up

ip link add link loop-south downlink type macvlan mode bridge
ip link set downlink up
ip addr add 10.30.2.1/24 dev downlink


sysctl -q net.ipv4.ip_forward=1
