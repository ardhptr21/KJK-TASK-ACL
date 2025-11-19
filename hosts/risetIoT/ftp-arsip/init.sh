grep -qxF 'nameserver 192.168.122.1' /etc/resolv.conf || echo 'nameserver 192.168.122.1' >> /etc/resolv.conf

apt update
apt install vsftpd -y

# SETUP FTP SERVER
# Buat 1 user untuk akses FTP
useradd -m -s /bin/bash risetIoT
echo "risetIoT:123" | chpasswd

# Buat file arsip.txt yang bisa diakses
echo "ARDHI GANTENG BANGET" > /home/risetIoT/arsip.txt
chown risetIoT:risetIoT /home/risetIoT/arsip.txt
chmod 644 /home/risetIoT/arsip.txt

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

# Buat user list file (hanya user risetIoT yang diizinkan)
cat > /etc/vsftpd.userlist << EOF
risetIoT
EOF

# Konfigurasi TCP Wrappers untuk membatasi akses hanya dari Mahasiswa dan Admin
# Asumsikan IP Mahasiswa: 10.30.30.1, IP Admin: 10.10.10.1
cat > /etc/hosts.allow << EOF
vsftpd: 10.30.30.1
vsftpd: 10.10.10.1
EOF

cat > /etc/hosts.deny << EOF
vsftpd: ALL
EOF

# Restart service
service vsftpd restart
