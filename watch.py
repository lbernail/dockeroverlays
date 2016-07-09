#!/usr/bin/env python

import os
import socket
import struct

# These constants map to constants in the Linux kernel. This is a crappy
# way to get at them, but it'll do for now.
RTMGRP_LINK = 1

NLMSG_NOOP = 1
NLMSG_ERROR = 2

RTM_NEWLINK = 16
RTM_DELLINK = 17
RTM_GETNEIGH = 30

IFLA_IFNAME = 3

# Create the netlink socket and bind to RTMGRP_LINK,
s = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, socket.NETLINK_ROUTE)
s.bind((os.getpid(), RTMGRP_LINK))

while True:
    data = s.recv(65535)
    msg_len, msg_type, flags, seq, pid = struct.unpack("=LHHLL", data[:16])

    if msg_type == NLMSG_NOOP:
        print "no-op"
        continue
    elif msg_type == NLMSG_ERROR:
        print "error"
        break

    # We fundamentally only care about NEWLINK messages in this version.
    if msg_type != RTM_NEWLINK:
        continue

    data = data[16:]

    family, _, if_type, index, flags, change = struct.unpack("=BBHiII", data[:16])

    remaining = msg_len - 32
    data = data[16:]

    while remaining:
        rta_len, rta_type = struct.unpack("=HH", data[:4])

        # This check comes from RTA_OK, and terminates a string of routing
        # attributes.
        if rta_len < 4:
            break

        rta_data = data[4:rta_len]

        increment = (rta_len + 4 - 1) & ~(4 - 1)
        data = data[increment:]
        remaining -= increment

        # Hoorah, a link is up!
        if rta_type == IFLA_IFNAME:
            print "New link %s" % rta_data
