#!/bin/bash


ip link add link access access.4093 type vlan id 4093 
ip link set access.4093 up
ip addr add 10.253.161.65/27 dev access.4093
iptables -t nat -A POSTROUTING -o eth2 -s 10.253.161.64/27  -j SNAT --to-source 29.29.0.1


