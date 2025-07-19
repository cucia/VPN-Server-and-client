#!/bin/bash
set -e
sudo apt update
sudo apt install -y wireguard

umask 077
wg genkey | tee server_private.key | wg pubkey > server_public.key

PRIVATE_KEY=$(cat server_private.key)
SERVER_IP=$(curl -s http://checkip.amazonaws.com)
VPN_PORT=51820

sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
Address = 10.10.0.1/24
SaveConfig = true
PrivateKey = $PRIVATE_KEY
ListenPort = $VPN_PORT
EOF

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

echo "✅ WireGuard installed and running on port $VPN_PORT"
echo "📌 Open UDP port 51820 in AWS Security Group!"
