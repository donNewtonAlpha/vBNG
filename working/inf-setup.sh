#!/bin/bash

ip addr add 10.20.1.21/24 dev eth1
ip link set eth1 mtu 9000
ip link set eth1 up
ip addr

./ethtool-fixups.sh eth1 off

