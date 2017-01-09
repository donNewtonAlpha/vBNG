echo ffffffff > /sys/class/net/eth1/queues/rx-0/rps_cpus
echo ffffffff > /sys/class/net/eth1/queues/rx-1/rps_cpus
echo ffffffff > /sys/class/net/eth2/queues/rx-1/rps_cpus
echo ffffffff > /sys/class/net/eth2/queues/rx-0/rps_cpus

echo ffffffff > /sys/class/net/eth1/queues/tx-0/xps_cpus
echo ffffffff > /sys/class/net/eth1/queues/tx-1/xps_cpus
echo ffffffff > /sys/class/net/eth2/queues/tx-1/xps_cpus
echo ffffffff > /sys/class/net/eth2/queues/tx-0/xps_cpus
