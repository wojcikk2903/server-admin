#!/usr/bin/env bash

sudo apt-get update

# Install other required packages
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    nginx

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce

# Prepare the environment

mkdir -p /var/lib/nosqlclient/data/db
chmod 777 /var/lib/nosqlclient/data/db

# Prepare Docker
docker pull mongoclient/mongoclient

# Run docker image
docker run -d -p 3000:3000 -v /var/lib/nosqlclient/data/db:/data/db --restart unless-stopped mongoclient/mongoclient

# Configure nginx
echo "admin:$apr1$g47QQSim$1Cm/yHpeKSL.yBIEo/O8h1" > /etc/nginx/htpasswd

wget https://raw.githubusercontent.com/femhub/server-admin/master/config/production/manager/nginx/sites-available -O /etc/nginx/sites-available/nosqlclient
cd /etc/nginx/sites-enabled
ln -s ../sites-available/nosqlclient

service nginx restart
