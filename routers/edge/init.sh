apt update
apt install iptables -y

# NAT configuration
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.20.0.0/16

# [=== FIREWALL RULES ===]
iptables -A FORWARD -s 10.20.50.0/24 -d 10.20.20.2 -p tcp --dport 80 -j REJECT # reject guest    -> akademik classroom HTTP
iptables -A FORWARD -s 10.20.30.0/24 -d 10.20.20.2 -p tcp --dport 80 -j REJECT # reject risetiot -> akademik classroom HTTP

iptables -A FORWARD -s 10.20.40.0/24 -d 10.20.20.0/24 -p tcp --dport 22 -j ACCEPT # allow admin -> akademik all ssh
iptables -A FORWARD -d 10.20.20.0/24 -p tcp --dport 22 -j REJECT                  # reject all  -> akademik all ssh

iptables -A FORWARD -d 10.20.20.4 -p tcp --dport 3306 -j REJECT # reject all