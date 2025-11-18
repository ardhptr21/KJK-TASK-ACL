grep -qxF 'nameserver 192.168.122.1' /etc/resolv.conf || echo 'nameserver 192.168.122.1' >> /etc/resolv.conf

apt update
apt install iptables -y