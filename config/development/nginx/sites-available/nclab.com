upstream frontends {
    server 127.0.0.1:8000;
}


# everything is redirected to https (strarting dot in server_name is for *. and no prefix)
server {
    listen      80;
    server_name .nclab.com;
    rewrite     ^   https://$host$request_uri? permanent;
}

server {
    listen 443 default ssl;
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_certificate        /etc/ssl/certs/desktop.dev.nclab.com.crt;
    ssl_certificate_key    /etc/ssl/private/desktop.dev.nclab.com.key;
    location / {
        proxy_pass http://frontends;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_set_header X-Scheme $scheme;
        proxy_read_timeout 3600;
        proxy_redirect off;
	    add_header 'Access-Control-Allow-Origin' '*';
    }
}
