#!/usr/bin/env bash

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root"
   exit 1
fi

VXLAN_ID=$1
TARGET_NS=$2

case $VXLAN_ID in
    ''|*[!0-9]*)
      VXLAN_ID=
   ;;
    *)
    ;;
esac

shift 2
VXLAN_OPTIONS="$@"
VXLAN_IF="vxlan$VXLAN_ID"
BRIDGE_IF="br$VXLAN_ID"


[ -z "$VXLAN_ID" ] || [ -z "$TARGET_NS" ] && {
    echo "Syntax:"
    echo "$0 <vxlan-id> host [vxlan options]" 
    echo "$0 <vxlan-id> <namespace> [vxlan options]" 
    echo "$0 <vxlan-id> container:<name> [vxlan options]" 
    exit 1
}

warn () {
  echo "$@" >&2
}

die () {
  status="$1"
  shift
  warn "$@"
  exit "$status"
}

check_if () {
  interface=$1
  namespace=${2:host}
  if [ "$namespace" == "host" ]; then
    if ip link show $interface > /dev/null 2>&1 ; then
        return 1
    fi
  else
    if ip netns exec $namespace ip link show $interface > /dev/null 2>&1 ; then
        return 1
    fi
  fi
  return 0 
}


[ ! -d /var/run/netns ] && mkdir -p /var/run/netns

case "$TARGET_NS" in
    host)
      TARGET_NS="host"
      ;;
    container:*)
      TARGET_NS="${TARGET_NS#*:}" 
      if ! GUEST_NS_PATH=$(docker inspect --format="{{ .NetworkSettings.SandboxKey}}" $TARGET_NS 2> /dev/null); then
         die 1 "No container $TARGET_NS"
      fi
      ln -sf "$GUEST_NS_PATH" "/var/run/netns/$TARGET_NS"
      ;;
    *)
      if ! ip netns exec "$TARGET_NS" ip addr show  > /dev/null 2>&1 ; then
          echo "Creating Namespace $TARGET_NS"
          ip netns add "$TARGET_NS"
     fi
esac

if ! check_if "$BRIDGE_IF" "$TARGET_NS"; then
    die 1 "Interface $BRIDGE_IF already exists in $TARGET_NS namespace"
fi
if ! check_if "$VXLAN_IF" "host"; then
    die 1 "Interface $VXLAN_IF already exists in host namespace"
fi
if ! check_if "$VXLAN_IF" "$TARGET_NS"; then
    die 1 "Interface $VXLAN_IF already exists in $TARGET_NS namespace"
fi

if ! ip link add dev $VXLAN_IF type vxlan id $VXLAN_ID dstport 4789 $VXLAN_OPTIONS ; then
    die 1 "Unable to create vxlan interface (invalid option or existing interface with vxlan id $VXLAN_ID)"
fi 

if [ "$TARGET_NS" == "host" ] ; then
    ip link add dev $BRIDGE_IF type bridge
    ip link set $VXLAN_IF master $BRIDGE_IF
    ip link set $VXLAN_IF up
    ip link set $BRIDGE_IF up
else
    ip netns exec "$TARGET_NS" ip link add dev $BRIDGE_IF type bridge
    sudo ip link set $VXLAN_IF netns "$TARGET_NS"
    ip netns exec "$TARGET_NS" ip link set $VXLAN_IF master $BRIDGE_IF
    ip netns exec "$TARGET_NS" ip link set $VXLAN_IF master $BRIDGE_IF
    ip netns exec "$TARGET_NS" ip link set $VXLAN_IF up
    ip netns exec "$TARGET_NS" ip link set $BRIDGE_IF up
fi
