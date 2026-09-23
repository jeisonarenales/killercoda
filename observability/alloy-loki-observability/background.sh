#!/bin/bash

set -ex

apt-get update
apt-get install -y tree gpg

mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/grafana.asc https://apt.grafana.com/gpg-full.key
chmod 644 /etc/apt/keyrings/grafana.asc
echo "deb [signed-by=/etc/apt/keyrings/grafana.asc] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list

apt-get update
apt-get install alloy

sed 's/CUSTOM_ARGS=""/CUSTOM_ARGS="--server.http.listen-addr=0.0.0.0:12345"/g' /etc/default/alloy

sudo systemctl enable alloy.service
sudo systemctl start alloy