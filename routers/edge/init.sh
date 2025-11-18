apt update
apt install iptables -y

# NAT configuration
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.20.0.0/16

# [=== FIREWALL RULES ===]
iptables -A FORWARD -i eth1 -d 10.20.20.2 -p tcp --dport 80 -j DROP
iptables -A OUTPUT -s 10.20.30.0/24 -d 10.20.20.2 -p tcp --dport 80 -j DROP