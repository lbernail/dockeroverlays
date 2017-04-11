#!/bin/bash

rip=${1:-2}
rhost=${2:-0.0.0.0}

sudo ip netns exec overns ip neighbor add 192.168.0.${rip} lladdr 02:42:c0:a8:00:0${rip} dev vxlan1 nud permanent
sudo ip netns exec overns bridge fdb add 02:42:c0:a8:00:0${rip} dev vxlan1 self dst ${rhost} vni 42 port 4789
