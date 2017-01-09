#!/bin/bash

gatewayip=20.20.0.1
bridge=access

third=$1
fourth=2

set -x


for i in $(seq 2 501)
do

   vif=${bridge}.${i}
   ip link add link $bridge $vif type vlan id $i ingress-qos-map 0:1 1:2 2:3 3:4 4:5 5:6 6:7 7:8 egress-qos-map 1:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7
   ip link set $vif up
   ip add add ${gatewayip}/32 dev $vif

   if  [ $fourth -gt 255 ]
   then
      fourth=0
      third=$((third + 1))
   fi

   echo $vif
   ip=20.20.${third}.${fourth}
   fourth=$((fourth+1))
   echo $ip
   ip route add $ip/32 dev $vif src $gatewayip
   
   #TODO:  gotta be an easier way...
   #vtysh -c "conf t" -c "ip route ${ip}/32 ${vif}" -c "end" 

   sh shaper.sh $vif 5mbit

done

vtysh -c "write mem"
