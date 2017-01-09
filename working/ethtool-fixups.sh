interface=$1
flowctl=$2

#ip link set ${interface} up

# turn on udp hashing to spread traffic out between rx queues (and CPU)
#ethtool -N ${interface} rx-flow-hash udp4 sdfn 
#ethtool -N p2p2 rx-flow-hash udp4 sdfn 

# increase the ring buffer size
#ethtool -G ${interface} rx 4096 tx 4096

# turn off flow control (dont do any favors to the recv)
#ethtool --pause ${interface} autoneg off rx ${flowctl} tx ${flowctl}

# increase the transmit queue length
ifconfig ${interface} txqueuelen 4096

#ifconfig ${interface} mtu 9000

#ethtool -K ${interface} tx off rx off tso off gso off gro off lro off sg off rxvlan off txvlan off


#cat /sys/class/net/${interface}/queues/rx-0/rps_cpus

#echo ffffffff > /sys/class/net/${interface}/queues/rx-0/rps_cpus
#echo ffffffff > /sys/class/net/${interface}/queues/rx-1/rps_cpus
#echo ffffffff > /sys/class/net/${interface}/queues/rx-2/rps_cpus
#echo ffffffff > /sys/class/net/${interface}/queues/rx-3/rps_cpus

#echo ffffffff > /sys/class/net/${interface}/queues/tx-0/xps_cpus
#echo ffffffff > /sys/class/net/${interface}/queues/tx-1/xps_cpus
#echo ffffffff > /sys/class/net/${interface}/queues/tx-2/xps_cpus
#echo ffffffff > /sys/class/net/${interface}/queues/tx-3/xps_cpus

