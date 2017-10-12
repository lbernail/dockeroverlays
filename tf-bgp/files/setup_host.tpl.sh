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

echo "Generating Quagga configuration"
mkdir -p  /home/${TF_USER}/quagga/
cat <<EOF > /home/${TF_USER}/quagga/Quagga.conf
${TF_QUAGGA_CONF}
EOF
cat <<EOF > /home/${TF_USER}/quagga/daemons
zebra=yes
bgpd=yes
ospfd=no
ospf6d=no
ripd=no
ripngd=no
isisd=no
EOF
cat <<EOF > /home/${TF_USER}/quagga/debian.conf
vtysh_enable=yes 
zebra_options=" --daemon -A 127.0.0.1 "
bgpd_options=" --daemon -A 127.0.0.1 "
EOF

chown -R ${TF_USER}:${TF_USER} /home/${TF_USER}/quagga

echo "Pulling images"
for image in ${TF_PULL_IMAGES}; do
    docker pull $image
done

echo "Starting Cumulus Quagga with docker"
if [ "${TF_START_QUAGGA}" == "yes" ]
then
   docker run -t -d --privileged --name quagga -p 179:179 --net=${TF_QUAGGA_NET} --hostname ${TF_HOSTNAME} -v /home/${TF_USER}/quagga:/etc/quagga cumulusnetworks/quagga:latest
fi
