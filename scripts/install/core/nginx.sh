#!/usr/bin/env bash

sudo apt -y install nginx

# TODO: This might be linked locally if ran from the repository
wget https://raw.githubusercontent.com/femhub/server-admin/master/config/production/nginx/sites-available/nclab.com -O /etc/nginx/sites-available/nclab.com
cd /etc/nginx/sites-enabled/
ln -s ../sites-available/nclab.com

# TODO: Make sure SSL certificates are properly placed
sudo service nginx restart
