apt update
apt install iptables -y

# NAT configuration
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.20.0.0/16

# [=== FIREWALL RULES ===]

# Block all access to admin network (10.20.10.0/24) from other routers
iptables -A FORWARD -s 10.20.30.0/24 -d 10.20.40.0/24 -j REJECT # reject mahasiswa -> admin all
iptables -A FORWARD -s 10.20.50.0/24 -d 10.20.40.0/24 -j REJECT # reject guest -> admin all
iptables -A FORWARD -s 10.20.20.0/24 -d 10.20.40.0/24 -j REJECT # reject akademik -> admin all
iptables -A FORWARD -s 10.20.10.0/24 -d 10.20.40.0/24 -j REJECT # reject risetIoT -> admin all

iptables -A FORWARD -s 10.20.50.0/24 -d 10.20.20.2 -p tcp --dport 80 -j REJECT # reject guest    -> akademik classroom HTTP
iptables -A FORWARD -s 10.20.30.0/24 -d 10.20.20.2 -p tcp --dport 80 -j REJECT # reject risetiot -> akademik classroom HTTP

iptables -A FORWARD -s 10.20.40.0/24 -d 10.20.20.0/24 -p tcp --dport 22 -j ACCEPT # allow admin -> akademik all ssh
iptables -A FORWARD -d 10.20.20.0/24 -p tcp --dport 22 -j REJECT                  # reject all  -> akademik all ssh

iptables -A FORWARD -d 10.20.20.4 -p tcp --dport 3306 -j REJECT # reject all


# IDS & IPS Configuration
apt install software-properties-common -y
add-apt-repository ppa:oisf/suricata-stable -y
apt update
apt install suricata -y

suricata-update
# suricata -c /etc/suricata/suricata.yaml -i eth0 -i eth1 -i eth2 -i eth3 -i eth4 -i eth5 -D -> af-packets mode
# suricata -c /etc/suricata/suricata.yaml -q 0 -D -> nfqeueue mode

# =CUSTOM=
# edit /etc/suricata/suricata.yaml
# add new file rules -> local.rules

echo 'alert http any any -> any any (msg:"WEB SHELL / BACKDOOR access detected"; flow:established,to_server; uricontent:".php"; nocase; pcre:"/((cmd|shell|upload|eval|exec|system|backdoor|cmd\.php|shell\.php|uploader|webshell)\.php)/i"; classtype:web-application-attack; sid:1002001; rev:1;)' >> /var/lib/suricata/rules/local.rules