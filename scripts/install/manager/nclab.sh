#!/usr/bin/env bash

# Prepare repository and install NCLab
mkdir -p ~/repo/git
cd ~/repo/git
git clone git@github.com:femhub/nclab
cd ~/repo/git/nclab
./install.sh

# Download configurations
# Root config
# Using default
# Core settings
wget https://raw.githubusercontent.com/femhub/server-admin/master/config/production/manager/settings.py -O /home/lab/core/settings.py