grep -qxF 'nameserver 192.168.122.1' /etc/resolv.conf || echo 'nameserver 192.168.122.1' >> /etc/resolv.conf

apt update
apt install vsftpd -y

# SETUP FTP SERVER
# Buat 2 user untuk akses FTP (mahasiswa dan admin)
useradd -m -s /bin/bash mahasiswa
echo "mahasiswa:123" | chpasswd

useradd -m -s /bin/bash admin
echo "admin:123" | chpasswd

# Buat file arsip.txt yang bisa diakses
mkdir -p /home/ftp-data
echo "Ini adalah data arsip yang dapat diakses melalui FTP server risetIoT" > /home/ftp-data/arsip.txt
chmod 755 /home/ftp-data
chmod 644 /home/ftp-data/arsip.txt

# Copy arsip.txt ke home directory masing-masing user
cp /home/ftp-data/arsip.txt /home/mahasiswa/
cp /home/ftp-data/arsip.txt /home/admin/
chown mahasiswa:mahasiswa /home/mahasiswa/arsip.txt
chown admin:admin /home/admin/arsip.txt

# Konfigurasi vsftpd
cat > /etc/vsftpd.conf << EOF
# Listen on IPv4
listen=YES
listen_ipv6=NO

# Disable anonymous login
anonymous_enable=NO

# Enable local users
local_enable=YES

# Enable write commands
write_enable=YES

# Set local umask
local_umask=022

# Enable chroot for security
chroot_local_user=YES
allow_writeable_chroot=YES

# Show messages
dirmessage_enable=YES

# Log file transfers
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log

# Connection settings
connect_from_port_20=YES
ftpd_banner=Welcome to FTP Arsip Server - risetIoT

# Passive mode settings
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000

# User list (only mahasiswa and admin can access)
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
EOF

# Buat user list file
cat > /etc/vsftpd.userlist << EOF
mahasiswa
admin
EOF

# Restart service
service vsftpd restart
