#!/bin/bash

hostname=${1}
template=${2}
phy=${3}

if [ -z "$hostname" ] || [ -z "$template" ] || [ -z "$phy" ]
then
  echo "Usage $0 <hostname> <template> <phy-data-plane>" 1>&2
  exit 1
fi


cwd=$(pwd)
cd /home/foundry/vbng/


set -x 

lxc-copy -n $template -N $hostname
cat sriov-tmpl.conf | sed s/%SRIOV-VF%/$phy/g >> /var/lib/lxc/${hostname}/config

echo 55 > /sys/class/net/${phy}/queues/rx-0/rps_cpus 
echo 55 > /sys/class/net/${phy}/queues/rx-1/rps_cpus 

lxc-start -d -n $hostname

cp -a *.sh /var/lib/lxc/${hostname}/rootfs/root/

cd $cwd
