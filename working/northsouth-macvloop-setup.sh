#!/bin/bash

set -x

modprobe ebtables

ip addr add 10.50.1.14/32 dev lo

#to internet / voip router to network 2.2.0.0/16
ip link set p1p2 up
ip addr add 10.40.1.0/31 dev p1p2

ip link add loop-north type dummy
ip link set loop-north up

ip link add link loop-north uplink type macvlan mode bridge
ip link set uplink up
ip addr add 10.30.1.1/24 dev uplink



ip link set p1p1 up
ip addr add 10.10.1.1/31 dev p1p1

ip link add loop-south type dummy
ip link set loop-south up

ip link add link loop-south downlink type macvlan mode bridge
ip link set downlink up
ip addr add 10.30.2.1/24 dev downlink


sysctl -q net.ipv4.ip_forward=1
