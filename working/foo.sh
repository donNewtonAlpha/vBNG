

ip link set eth1 address 02:01:01:01:01:02
sh vm-set-rps.sh 
./vbng-setup2.sh eth1 10.10.1.2/24 10.10.1.1 10.50.1.2 5002 10.50.1.1 20.20.0.1 eth2 10.40.1.2/24 10.40.1.1 2500mbit
# ./cust-bulk-setup.sh 0

