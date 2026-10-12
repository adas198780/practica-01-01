#!/bin/bash
set -ex
cd "$(dirname "$0")"
source .env

# --- Database user (so we don't use root in the web tools) ---
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# --- phpMyAdmin (non-interactive) ---
echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt install -y phpmyadmin php-mbstring php-zip php-gd php-curl

# --- Adminer ---
mkdir -p /var/www/html/adminer
wget -O /var/www/html/adminer/index.php \
  https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

# --- GoAccess + protected stats folder ---
apt install -y goaccess apache2-utils
mkdir -p /var/www/html/stats
cp ../htaccess/.htaccess /var/www/html/stats/.htaccess
htpasswd -bc /etc/apache2/.htpasswd "$STATS_USER" "$STATS_PASSWORD"
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED

systemctl restart apache2