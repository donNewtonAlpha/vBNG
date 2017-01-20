#!/bin/bash
#
# example:  ./vbng-destroy-stag.sh <phy> <stag-id>
#
#


phy=${1}
stag=${2}

if [ -z "$phy" ] || [ -z "$stag" ]
then
  echo "Usage $0 <phy> <svlan-tag-id>" 1>&2
  exit 1
fi


# TODO: hackjob for 802.1ad
ip link set ${phy}.${stag} down
ip link del ${phy}.${stag}
