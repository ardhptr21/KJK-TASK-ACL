grep -qxF 'nameserver 192.168.122.1' /etc/resolv.conf || echo 'nameserver 192.168.122.1' >> /etc/resolv.conf

apt update
apt install openssh-server -y

# SETUP SSH SERVER
useradd -m -s /bin/bash classroom
echo "admin:123" | chpasswd
service ssh restart