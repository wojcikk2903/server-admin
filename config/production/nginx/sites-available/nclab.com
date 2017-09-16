# frontends - places where tornado/core runs

upstream frontends {
    server 127.0.0.1:8000;
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
    server 127.0.0.1:8004;
    server 127.0.0.1:8005;
    server 127.0.0.1:8006;
    server 127.0.0.1:8007;
}

upstream adminfrontend {
    server 127.0.0.1:5000;
}

proxy_next_upstream error;

# php support, we run php-fpm
upstream php-devel {
    server unix:/var/run/php5-fpm.sock;
}


# we do not support unnamed queries, basic security
#server {
#    listen       80;
#    server_name  "";
#    return       444;
#}

# .cz domain redirected directly to ssl version
server {
    listen      80;
    server_name nclab.cz www.nclab.cz;
    rewrite     ^(.*)   https://nclab.com$1 permanent;
}

# everything is redirected to https (strarting dot in server_name is for *. and no prefix)
server {
    listen      80;
    server_name .nclab.com;
    rewrite     ^   https://$host$request_uri? permanent;
}

# this part takes care of nclab desktop only - matches subdomain and passes it as a root to frontend
server {
    listen 443 default ssl;
    server_name 	  desktop.nclab.com;

    ssl_stapling on;
    ssl_stapling_verify on;

    ssl_certificate        /etc/ssl/crt/desktop.nclab.com.crt;
    ssl_certificate_key    /etc/ssl/private/desktop.nclab.com.key;

    add_header Strict-Transport-Security max-age=31536000;

    client_max_body_size 50M;

    set $root /home/lab/core/static;

    error_page 403 /error403.html;
    error_page 502 /error502.html;

    location / {
        proxy_pass http://frontends;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_set_header X-Scheme $scheme;
        proxy_read_timeout 3600;
        proxy_redirect off;
	    add_header 'Access-Control-Allow-Origin' '*';
    }

# static content is served directly
    location ^~ /static/ {
        alias $root/;

	location ~* {
            add_header 'Access-Control-Allow-Origin' '*';
        }

    }

# we should probably rewrite it back to wp error pages
    location ~ ^/error\d\d\d.html$ {
        root $root/html/femhub/;
    }

# every browser asks for favicon
    location = /favicon.ico {
        log_not_found off;
        access_log off;
        rewrite (.*) /static/img/femhub/favicon.ico;
    }

    location = /robots.txt {
        log_not_found off;
        access_log off;
        rewrite (.*) /static/robots.txt;
    }

}

# this part takes care of nclab core accessible from vpn, we use only for load balancing of nodes requests
server {
    listen 80;
    server_name  10.8.3.1;

    client_max_body_size 50M;

    location / {
        proxy_pass http://frontends;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Scheme $scheme;
        proxy_read_timeout 3600;
        proxy_redirect off;
    }
}

# this part takes care of nclab admin only - matches subdomain and passes it as a root to frontend
server {
    listen 443 ssl;
    server_name           admin.nclab.com;

    # no OCSP stapling, self-signed certificate
    #ssl_stapling on;
    #ssl_stapling_verify on;

    ssl_certificate        /etc/ssl/crt/STAR_nclab_com.crt;
    ssl_certificate_key    /etc/ssl/private/STAR_nclab_com.key;

    add_header Strict-Transport-Security max-age=31536000;

    client_max_body_size 50M;

    set $root /home/lab/core/static;

    error_page 403 /error403.html;
    error_page 502 /error502.html;

    location / {
        auth_basic      "Restricted";
        auth_basic_user_file    /etc/nginx/htpasswd;
        proxy_pass http://adminfrontend;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Scheme $scheme;
        proxy_read_timeout 3600;
        proxy_redirect off;
	add_header Access-Control-Allow-Origin *;
    }

# static content is served directly
    location ^~ /static/ {
        alias $root/;

	location ~* {
                add_header Access-Control-Allow-Origin *;
        }
    }

# we should probably rewrite it back to wp error pages
    location ~ ^/error\d\d\d.html$ {
        root $root/html/femhub/;
    }

# every browser asks for favicon
    location = /favicon.ico {
        log_not_found off;
        access_log off;
        rewrite (.*) /static/img/femhub/favicon.ico;
    }

    location = /robots.txt {
        log_not_found off;
        access_log off;
        rewrite (.*) /static/robots.txt;
    }
}
