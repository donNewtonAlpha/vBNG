#!/bin/bash


if="$1"
ip="$2"
uid="$3"
rate="$4"


tc filter add dev $if parent ffff: protocol ip prio 4 u32 \
     match ip tos 0x00 0xfc \
     police rate $rate burst 1mbit \
     drop flowid $uid:3

