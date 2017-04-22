#!/bin/bash
set -e

echo "Setting hostname"
echo ${TF_HOSTNAME} > /etc/hostname
echo "$(hostname -I) ${TF_HOSTNAME}" >> /etc/hosts
hostname ${TF_HOSTNAME}

echo "Installing dependencies..."
apt-get update
apt-get install -y apt-transport-https ca-certificates tcpdump ethtool vim curl python-pip jq
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-engine

echo "Configuring docker service"
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/10-execstart-override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// --cluster-store=consul://${TF_CONSUL_ADDRESS}
EOF
systemctl daemon-reload
systemctl restart docker

echo "Adding admin user to docker group"
gpasswd -a admin docker

echo "Adding a few helpers for demo purposes"
ln -s /var/run/docker/netns /var/run/netns
curl -sSL https://github.com/lbernail/dockercon2017/archive/master.tar.gz | tar -xzf - --strip-components=1 -C /home/admin
chown -R admin:admin /home/admin
pip install pyroute2 python-consul
