# Script to tap IPv4 traffic to & from the public address assigned to the Residential Gateway
# Assumes a GRE tunnel to $DEST_IP 

IP_to_tap=$1
DEST_IP=$2


iptables -t mangle -D PREROUTING -d $IP_to_tap -j TEE --gateway $DEST_IP
iptables -t mangle -D PREROUTING -s $IP_to_tap -j TEE --gateway $DEST_IP
