# php support, we run php-fpm 
upstream php7 {
    server unix:/var/run/php/php7.0-fpm.sock;
}

# everything is redirected to https (strarting dot in server_name is for *. and no prefix)
server {
    listen      80;
    server_name .community.dev.nclab.com;
    rewrite     ^   https://$host$request_uri? permanent;
}

# main domain, takes care of WP
server {
    listen 443 ssl;
    server_name 	   community.dev.nclab.com;

    ssl_stapling on;
    ssl_stapling_verify on;

    ssl_certificate        /etc/nginx/ssl-keys/star.nclab.com_2018/star.nclab.com.bundle.crt;
    ssl_certificate_key    /etc/nginx/ssl-keys/star.nclab.com_2018/star.nclab.com.key;

    add_header Strict-Transport-Security max-age=31536000;

    client_max_body_size 50M;

# comment out for production version, enable only when you need to handle db
    #include /etc/nginx/sites-available/phpmyadmin;

    index index.php;

    root /var/www/community.dev.nclab.com/;
   # include /var/www/community.dev.nclab.com/nginx.conf;

# WP magic to enable permalinks
    location @wordpress {
       rewrite ^.*/files/(.*)$ /wp-includes/ms-files.php?file=$1 last;
        if (!-e $request_filename) {
           rewrite ^.+/?(/wp-.*) $1 last;
           rewrite ^.+/?(/.*\.php)$ $1 last;
           rewrite ^(.+)$ /index.php?q=$1 last;
        }
    }

# run php scripts
    location ~ \.php$ {
	root /var/www/community.dev.nclab.com/;
        try_files $uri $uri/ @wordpress;
        fastcgi_pass php7;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

# static content is served directly

    location / {
        root /var/www/community.dev.nclab.com/;
        try_files $uri $uri/ @wordpress;
        location ~*  \.(?:jpg|jpeg|png|gif|ico|css|js|svg)$ {
            expires 10d;
        }
        location ~*  \.(eot|ttf|otf|woff|woff2)$ {
            expires 10d;
            add_header Access-Control-Allow-Origin *;
        }
    }

    # General static, core, and other backend locations
    location ~ /static/ {
        proxy_pass        https://desktop05.dev.nclab.com;
        proxy_set_header  X-Real-IP  $remote_addr;
    }
    location ~ /(core|files|viewer|api|activate)/ {
        proxy_pass        https://desktop05.dev.nclab.com;
        proxy_set_header  X-Real-IP  $remote_addr;
    }


    error_log   /var/www/community.dev.nclab.com/log/nginx-error.log;

}
