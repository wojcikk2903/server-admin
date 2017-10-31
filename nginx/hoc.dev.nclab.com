# php support, we run php-fpm
upstream php {
         server unix:/var/run/php/php7.0-fpm.sock;
}

# everything is redirected to https (strarting dot in server_name is for *. and no prefix)
server {
    listen          80;
    server_name     hoc05.dev.nclab.com;
    rewrite     ^   https://$host$request_uri? permanent;
}

# root part takes care of WP
server {
    listen 443 ssl;
    server_name            hoc05.dev.nclab.com;
	ssl_certificate        /etc/ssl/certs/STAR-dev-ssl-bundle.crt;
	ssl_certificate_key    /etc/ssl/private/star_dev_nclab_com.key;
    client_max_body_size 50M;

    # comment out for production version, enable only when you need to handle db
    #include /etc/nginx/sites-available/phpmyadmin;
    # the hoc.dev.nclab.com/nginx-nclab.conf is not necessary for the current setup

    include /var/www/hoc.dev.nclab.com/nginx.conf;

    index index.php;
    root /var/www/hoc.dev.nclab.com;

    # WP magic to enable permalinks
    location @wordpress {
        rewrite ^.*/karel/files/(.*)$ /karel/wp-includes/ms-files.php?file=$1 last;
        rewrite ^.*/3d/files/(.*)$ /3d/wp-includes/ms-files.php?file=$1 last;
        if (!-e $request_filename) {
           rewrite ^.+/karel/?(/wp-.*) /karel/$1 last;
           rewrite ^.+/karel/?(/.*\.php)$ /karel/$1 last;
           rewrite ^/karel/(.+)$ /karel/index.php?q=$1 last;
           rewrite ^.+/3d/?(/wp-.*) /3d/$1 last;
           rewrite ^.+/3d/?(/.*\.php)$ /3d/$1 last;
           rewrite ^/3d/(.+)$ /3d/index.php?q=$1 last;
        }
    }

    # run php scripts
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini

        try_files $uri $uri/ @wordpress;
        fastcgi_pass php;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location = / {
        return 301 https://hoc05.dev.nclab.com/karel/;
    }

    # Karel HOC, internal rewrite of core requests from /karel/.../... to /.../...
    location /karel {
        index index.php index.html index.html;
        try_files $uri $uri/ /karel/index.php?$args;
    }
    location ~ /karel/static/ {
        rewrite /karel/static/(.*) /static/$1 last;
    }
    location ~ /karel/(core|files|viewer|api|activate)/ {
        rewrite /karel/(core|files|viewer|api|activate)/(.*) /$1/$2 last;
    }
    location = /karel/favicon.ico { log_not_found off; access_log off; }
    location = /karel/robots.txt  { log_not_found off; access_log off; }

    # 3D HOC, internal rewrite of core requests from /3d/.../... to /.../...
    location /3d {
        index index.php index.html index.html;
        try_files $uri $uri/ /3d/index.php?$args;
    }
    location ~ /3d/static/ {
        rewrite /3d/static/(.*) /static/$1 last;
    }
    location ~ /3d/(core|files|viewer|api|activate)/ {
        rewrite /3d/(core|files|viewer|api|activate)/(.*) /$1/$2 last;
    }
    location = /3d/favicon.ico { log_not_found off; access_log off; }
    location = /3d/robots.txt  { log_not_found off; access_log off; }

    # General static, core, and other backend locations
    location ~ /static/ {
        proxy_pass        https://desktop05.dev.nclab.com;
        proxy_set_header  X-Real-IP  $remote_addr;
    }
    location ~ /(core|files|viewer|api|activate)/ {
        proxy_pass        https://desktop05.dev.nclab.com;
        proxy_set_header  X-Real-IP  $remote_addr;
    }

    # logs
    error_log   /var/www/hoc.dev.nclab.com/log/nginx-error.log;
    #rewrite_log on;
}
