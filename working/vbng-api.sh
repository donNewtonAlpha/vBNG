#!/bin/bash

hostname=$1
template=$2
phy=$3
ipmask=$4
vni=$5
vxlanremote=$6
gatewayip=$7
remotenet=$8
nexthop=$9

echo "START"
echo "vbng-clone.sh $hostname $template $phy $ipmask $vni $vxlanremote $gatewayip $remotenet $nexthop"

/home/foundry/vbng/vbng-clone.sh $hostname $template $phy $ipmask $vni $vxlanremote $gatewayip $remotenet $nexthop 2>&1

echo "DONE"

exit 0
