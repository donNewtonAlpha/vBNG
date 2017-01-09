#!/bin/bash

set -x

for i in $(seq 0 7); do echo $i; cat /sys/class/net/eth1/queues/rx-$i/rps_cpus; echo ffffffff > /sys/class/net/eth1/queues/rx-$i/rps_cpus ; done
for i in $(seq 0 7); do echo $i; cat /sys/class/net/eth2/queues/rx-$i/rps_cpus; echo ffffffff > /sys/class/net/eth2/queues/rx-$i/rps_cpus ; done
