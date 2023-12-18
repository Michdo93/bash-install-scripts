#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

wget -O basic-install.sh https://install.pi-hole.net
bash basic-install.sh

# Pfad zu Pi-hole-Adlisten
adlists_dir="/etc/pihole"

# Array mit URLs zu den Adlisten
adlist_urls=(
    "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
    "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
    "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
    "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
    "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts;showintro=0"
    "https://raw.githubusercontent.com/GATmyIT/pihole-lists/master/notracking-hosts.txt"
    "https://raw.githubusercontent.com/Marfjeh/coinhive-block/master/domains"
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/KADhosts/hosts"
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Spam/hosts"
    "https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt"
    "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/UncheckyAds/hosts"
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.2o7Net/hosts"
    "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Risk/hosts"
    "https://raw.githubusercontent.com/Goooler/1024_hosts/master/hosts"
    "https://v.firebog.net/hosts/Prigent-Malware.txt"
    "https://v.firebog.net/hosts/Prigent-Phishing.txt"
    "https://v.firebog.net/hosts/Shalla-mal.txt"
    "https://v.firebog.net/hosts/Easyprivacy.txt"
    "https://v.firebog.net/hosts/Prigent-Ads.txt"
    "https://v.firebog.net/hosts/Easylist.txt"
    "https://v.firebog.net/hosts/AdguardDNS.txt"
    "https://v.firebog.net/hosts/static/w3kbl.txt"
    "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt"
    "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
    "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
    "https://phishing.army/download/phishing_army_blocklist_extended.txt"
    "https://zerodot1.gitlab.io/CoinBlockerLists/hosts"
    "https://tgc.cloud/downloads/hosts.txt"
    "https://reddestdream.github.io/Projects/MinimalHosts/etc/MinimalHostsBlocker/minimalhosts"
    "https://adaway.org/hosts.txt"
)

# Durchlaufe das Array und lade jede Adliste herunter
for adlist_url in "${adlist_urls[@]}"; do
    # Extrahiere den Dateinamen aus der URL
    adlist_file=$(basename "$adlist_url")
    # Lade die Adliste herunter
    curl -sSL "$adlist_url" > "$adlists_dir/$adlist_file"
done

# Aktualisiere Pi-hole, um die neuen Adlisten zu berücksichtigen
pihole -g

cd /opt/
git clone https://github.com/anudeepND/whitelist.git
python3 whitelist/scripts/whitelist.py

echo '0 23 * * 7 root /opt/whitelist/scripts/whitelist.py' | tee -a /etc/crontab

pihole -w \
accounts.google.com \
bit.ly \
doodle.com \
ec-ns.sascdn.com \
login.aliexpress.com \
paypal.com \
pinterest.com \
s.shopify.com \
sharepoint.com \
sourceforge.net \
twitter.com \
v.shopify.com \
versus.com \
www.paypalobjects.com \
