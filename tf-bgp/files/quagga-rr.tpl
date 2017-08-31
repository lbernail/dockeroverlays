! BGP will not initiate session over default routes
ip route ${TF_VPC_CIDR} 172.17.0.1

router bgp 65000
  bgp router-id ${TF_HOST_IP}
  bgp cluster-id ${TF_CLUSTER_ID}
  !
  ! Do not advertise any IPv4 addresses
  no bgp default ipv4-unicast
  !
  ! Accept connections from all hosts in ${TF_VPC_CIDR} with configuration from peer-group docker
  neighbor docker peer-group
  neighbor docker remote-as 65000
  bgp listen range ${TF_VPC_CIDR} peer-group docker
  !
  ! Advertise/Accept evpn addresses and act as a route reflector for peer-group docker
  address-family evpn
   neighbor docker activate
   neighbor docker route-reflector-client
