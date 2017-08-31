#!/bin/bash

sudo mkdir -p /var/run/netns
sudo rm -f /var/run/netns/overns

ctn=${1:-quagga}
quagga_ns=$(docker inspect --format="{{ .NetworkSettings.SandboxKey}}" $ctn)
sudo ln -s $quagga_ns /var/run/netns/overns

sudo ip netns exec overns ip link add dev br0 type bridge

sudo ip link add dev vxlan1 type vxlan id 42 dstport 4789
sudo ip link set vxlan1 netns overns
sudo ip netns exec overns ip link set vxlan1 master br0

sudo ip netns exec overns ip link set vxlan1 up
sudo ip netns exec overns ip link set br0 up
