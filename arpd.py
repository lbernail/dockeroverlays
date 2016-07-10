#!/usr/bin/env python

from pyroute2 import IPRSocket
from pyroute2 import IPRoute
from pyroute2.netlink.rtnl import ndmsg
from netconst import *

import logging

ctn_dns = {
  "ctn1" : "10.200.0.2",
  "ctn2" : "10.200.0.3",
}

ctn_arp = {
  "10.200.0.2": "02:42:0a:00:00:02",
  "10.200.0.3": "02:42:0a:00:00:03"
}

ctn_fib = {
  "02:42:0a:00:00:02" : "10.69.129.176",
  "02:42:0a:00:00:03" : "10.69.128.109"
}

logging.basicConfig(format='%(levelname)s %(message)s',level=logging.INFO)
ipr = IPRoute()
s = IPRSocket()
s.bind()

while True:
  msg=s.get()
  for m in msg:
    logging.debug('Received an event: {}'.format(m['event']))
    if m['event'] != 'RTM_GETNEIGH':
      continue

    logging.debug("Received a Neighbor miss")

    ifindex=m['ifindex']
    ifname=ipr.get_links(ifindex)[0].get_attr("IFLA_IFNAME")
    logging.debug("Family: {}".format(if_family.get(m['family'],m['family'])))
    logging.debug("Interface: {} (index: {})".format(ifname,ifindex))
    logging.debug("NUD State: {}".format(nud_state.get(m['state'],m['state'])))
    logging.debug("Flags: {}".format(m['flags']))
    logging.debug("Type: {}".format(type.get(m['ndm_type'],m['ndm_type'])))

    if m.get_attr("NDA_DST") is not None:
      ipaddr=m.get_attr("NDA_DST")
      logging.info("L3Miss on {}: Who has IP: {}?".format(ifname,ipaddr))
      if ipaddr in ctn_arp:
        logging.info("Populating ARP table: IP {} is {}".format(ipaddr,ctn_arp[ipaddr]))
        ipr.neigh('add', dst=ipaddr, lladdr=ctn_arp[ipaddr], ifindex=ifindex, state=ndmsg.states['permanent'])
       
    if m.get_attr("NDA_LLADDR") is not None:
      lladdr=m.get_attr("NDA_LLADDR")
      logging.info("L2Miss on {}: Who has Mac Address: {}?".format(ifname,lladdr))
      if lladdr in ctn_fib:
        logging.info("Populating FIB table: MAC {} is on host {}".format(lladdr,ctn_fib[lladdr]))
	ipr.fdb('add',ifindex=ifindex, lladdr=lladdr, dst=ctn_fib[lladdr])
