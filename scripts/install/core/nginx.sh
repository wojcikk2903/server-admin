#!/usr/bin/env bash

sudo apt -y install nginx

# TODO: This might be linked locally if ran from the repository
wget https://raw.githubusercontent.com/femhub/server-admin/master/config/production/nginx/sites-available/nclab.com -O /etc/nginx/sites-available/nclab.com
cd /etc/nginx/sites-enabled/
rm default
ln -s ../sites-available/nclab.com

cd /etc/nginx
echo admin:$apr1$g47QQSim$1Cm/yHpeKSL.yBIEo/O8h1 > htpasswd

# TODO: Make sure SSL certificates are properly placed
sudo service nginx restart
