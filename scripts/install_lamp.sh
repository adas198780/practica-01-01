#!/bin/bash
set -ex

# Always work from the folder where this script lives
cd "$(dirname "$0")"

apt update
apt install -y apache2 php libapache2-mod-php php-mysql mysql-server

cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf
cp ../php/index.php /var/www/html/index.php

systemctl restart apache2