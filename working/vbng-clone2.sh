#!/bin/bash

hostname=${1}
template=${2}

if [ -z "$hostname" ] || [ -z "$template" ] 
then
  echo "Usage $0 <hostname> <template>" 1>&2
  exit 1
fi


cwd=$(pwd)
cd /home/foundry/vbng/


set -x 

lxc-copy -n $template -N $hostname
cat macv-tmpl.conf >> /var/lib/lxc/${hostname}/config

lxc-start -d -n $hostname

cp -a *.sh /var/lib/lxc/${hostname}/rootfs/root/

cd $cwd

