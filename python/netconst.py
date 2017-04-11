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
