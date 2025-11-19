grep -qxF 'nameserver 192.168.122.1' /etc/resolv.conf || echo 'nameserver 192.168.122.1' >> /etc/resolv.conf

apt update
apt install nginx openssh-server php php-fpm -y

# SETUP WEB SERVER
echo "<h1>Open Course Server</h1>" > /var/www/html/index.html

cat <<EOF > /etc/nginx/sites-available/default
limit_req_zone \$binary_remote_addr zone=limiter:10m rate=2r/s;

server {
  listen 80 default_server;
  listen [::]:80 default_server;

  root /var/www/html;
  index index.html index.htm index.php;
  server_name _;

  location / {
    limit_req zone=limiter burst=5 nodelay;
    try_files \$uri \$uri/ =404;
  }

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    include fastcgi_params;
    fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
  }
}
EOF

service php8.3-fpm restart
service nginx restart

# SETUP SSH SERVER
useradd -m -s /bin/bash opencourse
echo "opencourse:123" | chpasswd
service ssh restart