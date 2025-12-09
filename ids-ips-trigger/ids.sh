# == RULE 1 ==
# from mahasiswa
nmap -sS 10.20.30.2

# == RULE 2 ==
# from mahasiswa
curl -LO -k https://github.com/v0re/dirb/raw/refs/heads/master/wordlists/small.txt
hydra -l student -P small.txt ssh://10.20.20.2

# == RULE 3 ==
# in riset
dd if=/dev/urandom of=rahasia.enc bs=1M count=1
# in mahasiswa
curl -O 10.20.10.2:4000/small.txt