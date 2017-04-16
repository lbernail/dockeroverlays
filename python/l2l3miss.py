#!/usr/bin/env python

# To use this without l2miss/l3miss from vxlan, enable app_solicit on your interface
# echo 1 | sudo tee -a  /proc/sys/net/ipv4/neigh/eth0/app_solicit

import os
import socket
import struct
import logging

# These constants map to constants in the Linux kernel.
# There is definitely a better way to get them
RTMGRP_LINK = 1
RTMGRP_NOTIFY = 2
RTMGRP_NEIGH = 4
RTMGRP_TC = 8


NLMSG_NOOP = 1
NLMSG_ERROR = 2

RTM_NEWLINK = 16
RTM_DELLINK = 17
RTM_GETNEIGH = 30



if_family = {2 : "AF_INET"}
nud_state = {
  0x01 : "NUD_INCOMPLETE",
  0x02 : "NUD_REACHABLE",
  0x04 : "NUD_STALE",
  0x08 : "NUD_DELAY",
  0x10 : "NUD_PROBE",
  0x20 : "NUD_FAILED",
  0x40 : "NUD_NOARP",
  0x80 : "NUD_PERMANENT",
  0x00 : "NUD_NONE"
}

type = {
  0 : "RTN_UNSPEC",
  1 : "RTN_UNICAST",
  2 : "RTN_LOCAL",
  3 : "RTN_BROADCAST",
  4 : "RTN_ANYCAST",
  5 : "RTN_MULTICAST",
  6 : "RTN_BLACKHOLE",
  7 : "RTN_UNREACHABLE",
  8 : "RTN_PROHIBIT",
  9 : "RTN_THROW",
  10 : "RTN_NAT",
  11 : "RTN_XRESOLVE"
}


nda_type = {
  0 : "NDA_UNSPEC",
  1 : "NDA_DST",
  2 : "NDA_LLADDR",
  3 : "NDA_CACHEINFO",
  4 : "NDA_PROBES",
  5 : "NDA_VLAN",
  6 : "NDA_PORT",
  7 : "NDA_VNI",
  8 : "NDA_IFINDEX",
  9 : "NDA_MASTER",
  10 : "NDA_LINK_NETNSID"
}

logging.basicConfig(level=logging.INFO)

# Create the netlink socket and bind to NEIGHBOR NOTIFICATION,
s = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, socket.NETLINK_ROUTE)
s.bind((os.getpid(), RTMGRP_NEIGH))

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
    if msg_type != RTM_GETNEIGH:
        continue

    data=data[16:]
    ndm_family, _, _, ndm_ifindex, ndm_state, ndm_flags, ndm_type = struct.unpack("=BBHiHBB", data[:12])
    logging.debug("Received a Neighbor miss")
    logging.debug("Family: {}".format(if_family.get(ndm_family,ndm_family)))
    logging.debug("Interface index: {}".format(ndm_ifindex))
    logging.debug("Family: {}".format(nud_state.get(ndm_state,ndm_family)))
    logging.debug("Flags: {}".format(ndm_flags))
    logging.debug("Type: {}".format(type.get(ndm_type,ndm_type)))

    data=data[12:]
    rta_len, rta_type = struct.unpack("=HH", data[:4])
    logging.debug("RT Attributes: Len: {}, Type: {}".format(rta_len,nda_type.get(rta_type,rta_type)))
  
    data=data[4:]
    if nda_type.get(rta_type,rta_type) == "NDA_DST":
      dst=socket.inet_ntoa(data[:4])
      logging.info("L3Miss: Who has IP: {}?".format(dst))

    if nda_type.get(rta_type,rta_type) == "NDA_LLADDR":
      mac="%02x:%02x:%02x:%02x:%02x:%02x" % struct.unpack("BBBBBB",data[:6])
      logging.info("L2Miss: Who has MAC: {}?".format(mac))
