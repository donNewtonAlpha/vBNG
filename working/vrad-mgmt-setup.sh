#!/bin/bash


ip link add link access access.4093 type vlan id 4093 
ip link set access.4093 up
ip addr add 10.253.161.65/29 dev access.4093

ip route del default via 10.64.1.254
ip route add 10.64.10.0/24 via 10.64.1.254
ip route add 10.64.11.0/24 via 10.64.1.254

