# Script to un_tap IPv4 traffic previously added with tap.sh

IP_to_tap=$1
DEST_IP=$2


iptables -t mangle -D PREROUTING -d $IP_to_tap -j TEE --gateway $DEST_IP
iptables -t mangle -D PREROUTING -s $IP_to_tap -j TEE --gateway $DEST_IP
