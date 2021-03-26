#!/bin/bash

#Import NGINX Licence Keys
#sudo mkdir -p /etc/ssl/nginx
cat <<EOT >>  /etc/ssl/nginx/nginx-repo.crt
${nginx_repo_cert}
EOT
cat <<EOT >> /etc/ssl/nginx/nginx-repo.key
${nginx_repo_key}
EOT

# Install N+
#- sudo wget https://cs.nginx.com/static/keys/nginx_signing.key && sudo apt-key add nginx_signing.key
#- sudo wget https://cs.nginx.com/static/keys/app-protect-security-updates.key && sudo apt-key add app-protect-security-updates.key
#- printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
#- printf "deb https://app-protect-security-updates.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/app-protect-security-updates.list
#- sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90nginx
#- sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90app-protect-security-updates
#- sudo apt-get update
#- sudo apt-get install nginx-plus

#Import PFS Config
cat <<EOT >> /tmp/pfs.conf
  # Perfect Forward Security
  # ssl_protocols TLSv1.2;
  # ssl_prefer_server_ciphers on;
  # ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4 !CBC";
  ssl_stapling on;
  ssl_stapling_verify on;
  # ssl_session_cache    shared:SSL:10m;
  # ssl_session_timeout  10m;
EOT

