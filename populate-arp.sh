#!/bin/bash

rip=${1:-2}
sudo ip netns exec overns ip neighbor add 192.168.0.${rip} lladdr 02:42:c0:a8:00:0${rip} dev vxlan1 nud permanent
