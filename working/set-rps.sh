for i in $(seq 0 7); do echo $i; cat /sys/class/net/p1p2_${i}/queues/rx-0/rps_cpus; echo 55555555 > /sys/class/net/p1p1_${i}/queues/rx-0/rps_cpus ; done
for i in $(seq 0 7); do echo $i; cat /sys/class/net/p1p2_${i}/queues/rx-0/rps_cpus; echo 55555555 > /sys/class/net/p1p2_${i}/queues/rx-0/rps_cpus ; done
