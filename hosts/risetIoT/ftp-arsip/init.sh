grep -qxF 'nameserver 192.168.122.1' /etc/resolv.conf || echo 'nameserver 192.168.122.1' >> /etc/resolv.conf

apt update
apt install vsftpd -y

# SETUP FTP SERVER
# Buat 3 user untuk akses FTP (mahasiswa read-only, admin dan risetIoT read-write)
useradd -m -s /bin/bash mahasiswa
echo "mahasiswa:123" | chpasswd

useradd -m -s /bin/bash admin
echo "admin:123" | chpasswd

useradd -m -s /bin/bash risetIoT
echo "risetIoT:123" | chpasswd

# Buat file arsip.txt yang bisa diakses di folder bersama
mkdir -p /home/ftp-shared
echo "ARDHI GANTENG BANGET" > /home/ftp-shared/arsip.txt

# Buat group untuk shared access
groupadd ftpshared
usermod -aG ftpshared mahasiswa
usermod -aG ftpshared admin
usermod -aG ftpshared risetIoT

# Set permission untuk folder shared
chown root:ftpshared /home/ftp-shared
chmod 775 /home/ftp-shared
chown root:ftpshared /home/ftp-shared/arsip.txt
chmod 664 /home/ftp-shared/arsip.txt

# Buat symbolic link dari home directory ke folder shared
ln -s /home/ftp-shared /home/mahasiswa/ftp-shared
ln -s /home/ftp-shared /home/admin/ftp-shared
ln -s /home/ftp-shared /home/risetIoT/ftp-shared

# Konfigurasi vsftpd
cat > /etc/vsftpd.conf << EOF
# Listen on IPv4
listen=YES
listen_ipv6=NO

# Disable anonymous login
anonymous_enable=NO

# Enable local users
local_enable=YES

# Enable write commands (akan dibatasi per user)
write_enable=YES

# Set local umask
local_umask=002

# Enable chroot for security
chroot_local_user=YES
allow_writeable_chroot=YES

# Allow symbolic links
allow_anon_ssl=NO

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

# Per-user configuration
user_config_dir=/etc/vsftpd/user_conf
EOF

# Buat user list file
cat > /etc/vsftpd.userlist << EOF
mahasiswa
admin
risetIoT
EOF

# Buat direktori untuk konfigurasi per-user
mkdir -p /etc/vsftpd/user_conf

# Konfigurasi untuk mahasiswa (read-only)
cat > /etc/vsftpd/user_conf/mahasiswa << EOF
# Read-only access
write_enable=NO
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO
EOF

# Konfigurasi untuk admin (read-write)
cat > /etc/vsftpd/user_conf/admin << EOF
# Full access (read-write)
write_enable=YES
EOF

# Konfigurasi untuk risetIoT (read-write)
cat > /etc/vsftpd/user_conf/risetIoT << EOF
# Full access (read-write)
write_enable=YES
EOF

# Konfigurasi TCP Wrappers untuk membatasi akses hanya dari Mahasiswa, Admin, dan risetIoT
cat > /etc/hosts.allow << EOF
vsftpd: 10.20.30.1
vsftpd: 10.20.10.1
vsftpd: 10.20.40.1
EOF

cat > /etc/hosts.deny << EOF
vsftpd: ALL
EOF

# Restart service
service vsftpd restart
