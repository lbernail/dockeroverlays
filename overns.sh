#!/usr/bin/env bash
set -e
set -x

sudo ip netns add overns
sudo ip netns exec overns ip link add dev br0 type bridge
sudo ip netns exec overns ip addr add dev br0 $bridge_gatway_cidr

# VXLAN must be created in the default NS. The outgoing UDP tunnel will use this NS
# https://stackoverflow.com/questions/28339364/linux-vxlan-driver-and-network-namespace
sudo ip link add dev vxlan1 type vxlan id 42 proxy learning dstport 4789
sudo ip link set vxlan1 netns overns
sudo ip netns exec overns ip link set vxlan1 master br0

sudo ip link add dev veth1 mtu 1450 type veth peer name veth2 mtu 1450
sudo ip link set dev veth1 netns overns
sudo ip netns exec overns ip link set veth1 master br0

sudo ip netns exec overns ip link set vxlan1 up
sudo ip netns exec overns ip link set veth1 up
sudo ip netns exec overns ip link set br0 up

#pid=`docker inspect -f '{{.State.Pid}}' test-overlay`
#sudo ln -sfn /proc/$pid/ns/net /var/run/netns/$pid

# Use the network NS created by docker
# Symlink to use it with standard userland commands (ip netns)
ctn_ns_path=$(docker inspect --format="{{ .NetworkSettings.SandboxKey}}" test-overlay)
ctn_ns=${ctn_ns_path##*/}
sudo ln -sfn $ctn_ns_path /var/run/netns/$ctn_ns
sudo ip link set dev veth2 netns $ctn_ns
sudo ip netns exec $ctn_ns ip link set dev veth2 name eth0 address $container1_mac_addr
sudo ip netns exec $ctn_ns ip addr add dev eth0 $container1_ip_cidr
sudo ip netns exec $ctn_ns ip link set dev eth0 up

sudo ip netns exec overns ip neighbor add $container2_ip lladdr $container2_mac_addr dev vxlan1 nud permanent
sudo ip netns exec overns bridge fdb add $container2_mac_addr dev vxlan1 self dst $container2_host_ip vni 42 port 4789
