#!/bin/bash

gatewayip=20.20.0.1

third=0
fourth=2

#set -x

for i in $(seq 2 2)
do

  cat ~/vBNG/template/01-vbng-stag-vlan-X \
  | sed s/%SVLAN_ID%/${i}/g \
  > /etc/network/interfaces.d/01-vbng-stag-vlan-${i}

  for j in $(seq 2 5)
  do
    if  [ $fourth -gt 255 ]
    then
      fourth=0
      third=$((third + 1))
    fi


    ip=20.20.${third}.${fourth}
    fourth=$((fourth+1))
    echo $ip

    cat ~/vBNG/template/10-vbng-customer-X-Y \
    | sed s/%SVLAN_ID%/${i}/g \
    | sed s/%CVLAN_ID%/${j}/g \
    | sed s/%GATEWAY_IP%/${gatewayip}/g \
    | sed s/%CUSTOMER_IP%/${ip}/g \
    | sed s/%SHAPE_RATE%/10mbit/g \
    > /etc/network/interfaces.d/10-vbng-customer-${i}-${j}

  done

done
