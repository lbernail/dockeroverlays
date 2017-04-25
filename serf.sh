#!/bin/bash

echo
echo "#########################################"
echo "#########################################"
echo "New event: ${SERF_EVENT}"
while read line; do
    printf "${line}\n"
done
echo "#########################################"
echo "#########################################"
echo
