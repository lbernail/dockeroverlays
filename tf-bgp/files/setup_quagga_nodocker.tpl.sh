#!/bin/bash
set -e

echo "Setting hostname"
echo ${TF_HOSTNAME} > /etc/hostname
echo "${TF_HOST_IP} ${TF_HOSTNAME}" >> /etc/hosts
hostname ${TF_HOSTNAME}

echo "Installing dependencies..."
apt-get update
apt-get install -y apt-transport-https ca-certificates tcpdump ethtool vim curl python-pip jq unzip iputils-arping
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-engine

echo "Adding ${TF_USER} user to docker group"
gpasswd -a ${TF_USER} docker

echo "Adding a few helpers for demo purposes"
curl -sSL https://github.com/lbernail/dockercon2017/archive/master.tar.gz | tar -xzf - --strip-components=1 -C /home/${TF_USER}
chown -R ${TF_USER}:${TF_USER} /home/${TF_USER}

echo "Installing cumulus Quagga"
apt-get install -y iproute libsnmp30
curl -sSL http://cumulusfiles.s3.amazonaws.com/roh-3.3.2-ubuntu1604.tar | tar -xC /tmp
dpkg -i /tmp/quagga_*

cat <<EOF > /etc/quagga/daemons
zebra=yes
bgpd=yes
ospfd=no
ospf6d=no
ripd=no
ripngd=no
isisd=no
pimd=no
ldpd=no
EOF

systemctl enable quagga
systemctl start quagga
