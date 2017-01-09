#!/bin/bash

modprobe ebtables

set -x

ip link set p1p2 up

echo 8 > /sys/class/net/p1p2/device/sriov_numvfs 

ip link set p1p1 up

echo 8 > /sys/class/net/p1p1/device/sriov_numvfs 

rmmod ixgbevf

sysctl -q net.ipv4.ip_forward=1
