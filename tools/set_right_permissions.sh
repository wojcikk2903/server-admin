#!/bin/bash
chgrp -R www-data /var/www/
echo "All files in /var/www are now owned by www-data group"
chmod -R 775 /var/www
echo "chmod 775 set up"
