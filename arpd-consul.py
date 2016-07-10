#!/usr/bin/env python

from pyroute2 import NetNS
from pyroute2.netlink.rtnl import ndmsg

import consul

import logging

from netconst import *

vxlan_ns="overns"

consul_host="consul1"
consul_prefix="demo"

logging.basicConfig(format='%(levelname)s %(message)s',level=logging.DEBUG)

ipr = NetNS(vxlan_ns)
ipr.bind()

c=consul.Consul(host=consul_host,port=8500)
idx,root_keys=c.kv.get(consul_prefix+"/",keys=True,separator="/")
logging.debug("Root Keys: {}".format(",".join(root_keys)))

while True:
  msg=ipr.get()
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

      (idx,answer)=c.kv.get(consul_prefix+"/arp/"+ipaddr)
      if answer is not None:
        mac_addr=answer["Value"]
        logging.info("Populating ARP table from Consul: IP {} is {}".format(ipaddr,mac_addr))
        ipr.neigh('add', dst=ipaddr, lladdr=mac_addr, ifindex=ifindex, state=ndmsg.states['permanent'])
       
    if m.get_attr("NDA_LLADDR") is not None:
      lladdr=m.get_attr("NDA_LLADDR")
      logging.info("L2Miss on {}: Who has Mac Address: {}?".format(ifname,lladdr))

      (idx,answer)=c.kv.get(consul_prefix+"/fib/"+lladdr)
      if answer is not None:
        dst_host=answer["Value"]
        logging.info("Populating FIB table from Consul: MAC {} is on host {}".format(lladdr,dst_host))
	ipr.fdb('add',ifindex=ifindex, lladdr=lladdr, dst=dst_host)
