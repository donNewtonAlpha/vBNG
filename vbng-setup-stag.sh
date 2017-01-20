#!/bin/bash
#
# example:  ./vbng-setup-stag.sh <phy> <stag-id>
#
#


phy=${1}
stag=${2}

if [ -z "$phy" ] || [ -z "$stag" ]
then
  echo "Usage $0 <phy> <svlan-tag-id>" 1>&2
  exit 1
fi

set -x

# TODO: hackjob for 802.1ad
ip link add link ${phy} ${phy}.${stag} type vlan proto 802.1ad id ${stag}
ip link set ${phy}.${stag} up
