#!/bin/bash

json=$1

if [ -z "$json" ]
then
  echo "Usage $0 <flattened-json-string>"
  exit 1
fi

echo "incoming json: $json"

hostname=$(echo $json | jq -r '.Hostname')
template=$(echo $json | jq -r '.Template')
phy=$(echo $json | jq -r '.Interface')
ipmask=$(echo $json | jq -r '.IpSubnet')
vni=$(echo $json | jq -r '.VxlanVni')
vxlanremote=$(echo $json | jq -r '.VxlanEndpoint')
gatewayip=$(echo $json | jq -r '.HostedGateway')
remotenet=$(echo $json | jq -r '.Route')
nexthop=$(echo $json | jq -r '.NextHop')

echo "START"
echo "vbng-clone.sh $hostname $template $phy $ipmask $vni $vxlanremote $gatewayip $remotenet $nexthop"

/home/foundry/vbng/vbng-clone.sh $hostname $template $phy $ipmask $vni $vxlanremote $gatewayip $remotenet $nexthop 2>&1

echo "DONE"

exit 0
