${TF_QUAGGA_NET == "bridge" ? "ip route ${TF_VPC_CIDR} 172.17.0.1\n" : "ip route ${TF_VPC_CIDR} ${TF_GATEWAY}\n"}
router bgp 65000
  bgp router-id ${TF_HOST_IP}
  !
  ! Do not advertise any IPv4 addresses
  no bgp default ipv4-unicast
  !
  neighbor reflectors peer-group
  neighbor reflectors remote-as 65000
  neighbor reflectors capability extended-nexthop
  !
  ${join("\n  ",formatlist("neighbor %s peer-group reflectors",split(",",TF_ROUTE_REFLECTORS)))}
  !
  ! Advertise/Accept evpn addresses with route reflectors
  address-family evpn
    neighbor reflectors activate
    advertise-all-vni
