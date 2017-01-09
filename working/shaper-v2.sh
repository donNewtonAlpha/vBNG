#!/bin/bash

if=$1
ceiling=$2

tc qdisc delete dev $if root
tc qdisc add dev $if root tbf rate $ceiling burst 5kb latency 70ms 

#Usage: ... tbf limit BYTES burst BYTES[/BYTES] rate KBPS [ mtu BYTES[/BYTES] ]
#               [ peakrate KBPS ] [ latency TIME ] [ overhead BYTES ] [ linklayer TYPE ]

