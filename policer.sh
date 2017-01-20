#!/bin/bash


uplinkphy="$1"
policerate="$2"
uid="$3"

if [ -z "$uplinkphy" ] || [ -z "$policerate" ] || [ -z "$uid" ]
then
  echo "Usage $0 <northbound-interface> <southbound-polic-rate> <uid>" 1>&2
  exit 1
fi



tc qdisc add dev $uplinkphy handle ffff: ingress
tc filter add dev $uplinkphy parent ffff: protocol ip prio 4 u32 \
   match ip tos 0x00 0xfc \
   police rate $policerate burst 1mbit \
   drop flowid $uid:3

