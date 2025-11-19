grep -qxF 'nameserver 192.168.122.1' /etc/resolv.conf || echo 'nameserver 192.168.122.1' >> /etc/resolv.conf

apt update
apt install vsftpd -y

# Setup Users
useradd -m -s /bin/bash mahasiswa || true
echo "mahasiswa:123" | chpasswd

useradd -m -s /bin/bash admin || true
echo "admin:123" | chpasswd

# Buat group shared
groupadd ftpshared || true
usermod -aG ftpshared mahasiswa
usermod -aG ftpshared admin

# Buat folder fisik sumber
mkdir -p /home/ftp-shared
chown root:ftpshared /home/ftp-shared
chmod 775 /home/ftp-shared

# Buat folder mount point di dalam home user
mkdir -p /home/mahasiswa/ftp-shared
mkdir -p /home/admin/ftp-shared

# Ubah owner mount point agar user bisa masuk
chown mahasiswa:mahasiswa /home/mahasiswa/ftp-shared
chown admin:admin /home/admin/ftp-shared

# Lakukan Mounting (Bind Mount) pengganti Symlink
mount --bind /home/ftp-shared /home/mahasiswa/ftp-shared
mount --bind /home/ftp-shared /home/admin/ftp-shared

# Masukkan ke fstab agar permanen saat restart
grep -qxF '/home/ftp-shared /home/mahasiswa/ftp-shared none bind 0 0' /etc/fstab || echo '/home/ftp-shared /home/mahasiswa/ftp-shared none bind 0 0' >> /etc/fstab
grep -qxF '/home/ftp-shared /home/admin/ftp-shared none bind 0 0' /etc/fstab || echo '/home/ftp-shared /home/admin/ftp-shared none bind 0 0' >> /etc/fstab

cat > /etc/vsftpd.conf << EOF
# Listen setup
listen=YES
listen_ipv6=NO

# Access Rights
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=002

# Security: Chroot
chroot_local_user=YES
allow_writeable_chroot=YES

# Messaging & Logging
dirmessage_enable=YES
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log

# Connection
connect_from_port_20=YES
ftpd_banner=Welcome to FTP Arsip Server - risetIoT

# Passive Mode (Wajib jika di belakang NAT/Firewall)
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000

# User Whitelist
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO

# Per-User Config
user_config_dir=/etc/vsftpd/user_conf
EOF

cat > /etc/vsftpd.userlist << EOF
mahasiswa
admin
EOF

mkdir -p /etc/vsftpd/user_conf

# -- Mahasiswa (READ ONLY) --
cat > /etc/vsftpd/user_conf/mahasiswa << EOF
write_enable=NO
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO
EOF

# -- Admin (READ WRITE) --
cat > /etc/vsftpd/user_conf/admin << EOF
write_enable=YES
EOF

# 8. Restart Service
service vsftpd restart