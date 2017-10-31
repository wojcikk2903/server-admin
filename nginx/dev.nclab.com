#upstream frontends {
#    server 127.0.0.1:8000;
#    server 127.0.0.1:8001;
#    server 127.0.0.1:8002;
#    server 127.0.0.1:8003;
#}

#upstream adminfrontend {
#    server 127.0.0.1:5000;
#}

proxy_next_upstream error;

# php support, we run php-fpm 
upstream php-devel {
    #server 127.0.0.1:9000;
    server unix:/var/run/php/php7.0-fpm.sock;
}

# everything is redirected to https (strarting dot in server_name is for *. and no prefix)
server {
    listen      80;
    server_name web05.dev.nclab.com;
    rewrite     ^   https://$host$request_uri? permanent;
}


# main domain, takes care of WP
server {
    listen 443 default ssl;
    server_name 	   web05.dev.nclab.com;

    ssl_stapling on;
    ssl_stapling_verify on;

	ssl_certificate        /etc/ssl/certs/STAR-dev-ssl-bundle.crt;
	ssl_certificate_key    /etc/ssl/private/star_dev_nclab_com.key;

    add_header Strict-Transport-Security max-age=31536000;
    
    # Adding cors headers for master servers - not testing etc.
    set $cors_origin "";
    # Please add hq in the future
    if ($http_origin ~* (https?://(desktop|admin|hoc|www|karelcoding)?\.?(nclab|karelcoding)\.com$) ) {
        set $cors_origin "*";
    }
    add_header Access-Control-Allow-Origin $cors_origin;

    client_max_body_size 50M;

# comment out for production version, enable only when you need to handle db
    #include /etc/nginx/sites-available/phpmyadmin;

    index index.php;

    root /var/www/dev.nclab.com/;
    include /var/www/dev.nclab.com/nginx.conf;

    rewrite ^/sitemap_index\.xml$ /index.php?sitemap=1 last;
    rewrite ^/([^/]+?)-sitemap([0-9]+)?\.xml$ /index.php?sitemap=$1&sitemap_n=$2 last;
    rewrite ^/(qsign/[0-9a-zA-Z\-]+)(.*)$   https://desktop05.dev.nclab.com/$1$2 permanent;

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
	root /var/www/dev.nclab.com/;
        try_files $uri $uri/ @wordpress;
        fastcgi_pass php-devel;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

# static content is served directly
    location ^~ /static/ {
        proxy_pass        https://desktop05.dev.nclab.com;
        proxy_set_header  X-Real-IP  $remote_addr;
        expires 10d;
    }

    location / {
        root /var/www/dev.nclab.com/;
        try_files $uri $uri/ @wordpress;
        location ~*  \.(?:jpg|jpeg|png|gif|ico|css|js|svg)$ {
            expires 10d;
        }
        location ~*  \.(eot|ttf|otf|woff|woff2)$ {
            expires 10d;
            add_header Access-Control-Allow-Origin *;
        }
    }

    location ~ /(core|files|viewer|api|activate)/ {
        proxy_pass        https://desktop05.dev.nclab.com;
        proxy_set_header  X-Real-IP  $remote_addr;
    }

    error_log   /var/www/dev.nclab.com/log/nginx-error.log;

}
