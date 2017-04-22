#!/usr/bin/env bash
set -e

echo "Setting hostname"
echo ${TF_HOSTNAME} > /etc/hostname
echo "$(hostname -I) ${TF_HOSTNAME}" >> /etc/hosts
hostname ${TF_HOSTNAME}

echo "Installing dependencies..."
apt-get update -y
apt-get upgrade -y
apt-get install -y unzip

echo "Fetching Consul..."
CONSUL=${TF_CONSUL_VERSION}
cd /tmp
wget https://releases.hashicorp.com/consul/$${CONSUL}/consul_$${CONSUL}_linux_amd64.zip -O consul.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
mv consul /usr/local/bin/consul

cat > /etc/sysconfig/consul <<EOF
CONSUL_FLAGS="-server -dev -ui -client 0.0.0.0"
EOF

mkdir -p /etc/systemd/system/consul.d
cat > /etc/systemd/system/consul.service << EOF
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/consul
Restart=on-failure
ExecStart=/usr/local/bin/consul agent \$CONSUL_FLAGS -config-dir=/etc/systemd/system/consul.d
ExecReload=/bin/kill -HUP \$MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

systemctl enable consul.service
systemctl start consul.service
