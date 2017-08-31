#!/bin/bash
set -e
set -x

BRIDGE=$1

# default value set further down if not set here
CONTAINER_IFNAME=
if [ "$2" = "-i" ]; then
  CONTAINER_IFNAME=$3
  shift 2
fi
CONTAINER_IFNAME=${CONTAINER_IFNAME:-eth0}

MTU=1500
if [ "$2" = "-m" ]; then
  MTU=$3
  shift 2
fi

GUESTNAME=$2
IPADDR=$3
MACADDR=$4

case "$BRIDGE" in
  *@*)
    BR_NAMESPACE="${BRIDGE#*@}"
    BRIDGE="${BRIDGE%%@*}"
    ;;
  *)
    BR_NAMESPACE=
    ;;
esac

# did they ask to generate a custom MACADDR?
# generate the unique string
case "$MACADDR" in
  U:*)
    macunique="${MACADDR#*:}"
    # now generate a 48-bit hash string from $macunique
    MACADDR=$(echo $macunique|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
   ;;
esac

case "$IPADDR" in
    */*@*)
      GATEWAY="${IPADDR#*@}" GATEWAY="${GATEWAY%%@*}"
      IPADDR="${IPADDR%%@*}"
      ;;
    # No gateway? We need at least a subnet, anyway!
    */*) : ;;
    # ... No? Then stop right here.
    *)
      warn "The IP address should include a netmask."
      die 1 "Maybe you meant $IPADDR/24 ?"
      ;;
esac

GUEST_NS_PATH=$(docker inspect --format="{{ .NetworkSettings.SandboxKey}}" $GUESTNAME)
#GUEST_NS=${GUEST_NS_PATH##*/}
GUEST_NS=$GUESTNAME
[ ! -d /var/run/netns ] && mkdir -p /var/run/netns
ln -sf "$GUEST_NS_PATH" "/var/run/netns/$GUEST_NS"

LOCAL_IFNAME="v${CONTAINER_IFNAME}pl${GUEST_NS:0:8}"
GUEST_IFNAME="v${CONTAINER_IFNAME}pg${GUEST_NS:0:8}"

# create veth interfaces
ip link add name "$LOCAL_IFNAME" mtu "$MTU" type veth peer name "$GUEST_IFNAME" mtu "$MTU"

# Connect local interface to the bridge (in a namespace if necessary)
if [ "$BR_NAMESPACE" ]; then
    ip link set dev "$LOCAL_IFNAME" netns "$BR_NAMESPACE"
    ip netns exec "$BR_NAMESPACE" ip link set "$LOCAL_IFNAME" master $BRIDGE
    ip netns exec "$BR_NAMESPACE" ip link set "$LOCAL_IFNAME" up
else
    ip link set "$LOCAL_IFNAME" master $BRIDGE
    ip link set "$LOCAL_IFNAME" up
fi

ip link set dev "$GUEST_IFNAME" netns "$GUEST_NS"
ip netns exec "$GUEST_NS" ip link set "$GUEST_IFNAME" name "$CONTAINER_IFNAME"
[ "$MACADDR" ] && ip netns exec "$GUEST_NS" ip link set dev "$CONTAINER_IFNAME" address "$MACADDR"
ip netns exec "$GUEST_NS" ip addr add "$IPADDR" dev "$CONTAINER_IFNAME"
ip netns exec "$GUEST_NS" ip link set "$CONTAINER_IFNAME" up

[ "$GATEWAY" ] && ip netns exec "$GUEST_NS" ip route add default via "$GATEWAY" dev "$CONTAINER_IFNAME"

echo $GUEST_NS
