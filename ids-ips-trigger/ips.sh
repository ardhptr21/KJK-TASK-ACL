# RULE 1
# from mahasiswa
nmap -sS 10.20.40.2

# RULE 2
# from mahasiswa
ssh root@10.20.40.2 # or hydra

# RULE 3
# from mahasiswa
curl -X POST -d "evil" http://10.20.20.3/upload.php -v