#!/bin/bash

sudo ip netns delete overns 2> /dev/null && echo "Deleting existing overlay"
sudo ip netns add overns
sudo ip netns exec overns ip link add dev br0 type bridge
sudo ip netns exec overns ip addr add dev br0 192.168.0.1/24

sudo ip link add dev vxlan1 type vxlan id 42 proxy learning l2miss l3miss dstport 4789
sudo ip link set vxlan1 netns overns
sudo ip netns exec overns ip link set vxlan1 master br0

sudo ip netns exec overns ip link set vxlan1 up
sudo ip netns exec overns ip link set br0 up
