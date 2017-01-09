#!/bin/bash

TemplateFile=$1
Hostname=$2
Interface=$3
RpsMask=$4


if [ -z "$TemplateFile" ] || [ -z "$Hostname" ] || [ -z "$Interface" ] || [ -z "$RpsMask" ]
then
  echo "Usage $0 <lxc-interface-template-file> <container-hostname> <sriov-vf-interface> <rps-cpu-mask> "
  exit 1
fi


cat $TemplateFile | sed s/%SRIOV-VF%/${Interface}/g >> /var/lib/lxc/${Hostname}/config
echo $RpsMask > /sys/class/net/${Interface}/queues/rx-0/rps_cpus 

# TODO: Not always there... need to know why
#echo $RpsMask > /sys/class/net/${Interface}/queues/rx-1/rps_cpus 

