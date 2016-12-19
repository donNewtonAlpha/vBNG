#!/bin/bash
#rates must be in format 10Mbit or 50Kbit etc

if=$1
ceiling=$2
main_rate=$3
ef_rate=$4
af_rate=$5
be_rate=$6

tc qdisc delete dev $if root

# - Main htb qdisc & class
tc qdisc add dev $if handle 1:0 root htb
tc class add dev $if parent 1:0 classid 1:1 htb rate $main_rate ceil $ceiling


# - EF Class (2:1)
tc class add dev $if parent 1:1 classid 1:11 htb rate $ef_rate ceil $ceiling
tc qdisc add dev $if parent 1:11 pfifo limit 3
tc filter add dev $if parent 1:0 prio 1 handle 7 fw flowid 1:11

# - AF Class (2:2)
tc class add dev $if parent 1:1 classid 1:12 htb rate $af_rate ceil $ceiling
tc qdisc add dev $if parent 1:12 pfifo limit 5
tc filter add dev $if parent 1:0 prio 1 handle 3 fw flowid 1:12

# - BE Class (2:3) 
tc class add dev $if parent 1:1 classid 1:13 htb rate $be_rate ceil $ceiling

tc qdisc add dev $if parent 1:13 red limit 60KB min 10KB max 45KB \
burst 20 avpkt 1000 bandwidth 1Mbit probability 0.01
tc filter add dev $if parent 1:0 protocol ip prio 2 u32 match ip dst 0.0.0.0/0 flowid 1:13

