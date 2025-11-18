grep -qxF 'nameserver 192.168.122.1' /etc/resolv.conf || echo 'nameserver 192.168.122.1' >> /etc/resolv.conf

apt update
apt install nginx openssh-server -y

# SETUP WEB SERVER
service nginx restart
echo "<h1>Classroom Server</h1>" > /var/www/html/index.html

# SETUP SSH SERVER
useradd -m -s /bin/bash classroom
echo "classroom:123" | chpasswd
service ssh restart