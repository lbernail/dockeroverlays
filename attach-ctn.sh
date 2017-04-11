#!/bin/bash

ctn=${1:-demo}
ip=${2:-2}

ctn_ns_path=$(docker inspect --format="{{ .NetworkSettings.SandboxKey}}" $ctn)
ctn_ns=${ctn_ns_path##*/}

sudo ip link add dev veth1 mtu 1450 type veth peer name veth2 mtu 1450
sudo ip link set dev veth1 netns overns
sudo ip netns exec overns ip link set veth1 master br0
sudo ip netns exec overns ip link set veth1 up

sudo ip link set dev veth2 netns $ctn_ns
sudo ip netns exec $ctn_ns ip link set dev veth2 name eth0 address 02:42:c0:a8:00:0${ip}
sudo ip netns exec $ctn_ns ip addr add dev eth0 192.168.0.${ip}/24
sudo ip netns exec $ctn_ns ip link set dev eth0 up
