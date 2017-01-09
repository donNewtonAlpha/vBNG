#!/bin/bash

modprobe ebtables

#to internet / voip router to network 2.2.0.0/16
ip link set p5p1 up
ip addr add 10.40.1.0/31 dev p5p1

echo 20 > /sys/class/net/p1p1/device/sriov_numvfs 

ip link add loop-north type dummy
ip link set loop-north up

ip link add link loop-north uplink type macvlan mode bridge
ip link set uplink up
ip addr add 10.30.1.1/24 dev uplink

ip link set p1p1 up

sysctl -q net.ipv4.ip_forward=1
