#!/bin/bash

#Import NGINX Licence Keys
echo ${nginx_repo_cert} >> /etc/ssl/nginx/nginx-repo.crt
echo ${nginx_repo_key} >> /etc/ssl/nginx/nginx-repo.key

#Import PFS Config
cat <<EOT >> ~/pfs.conf
  # Perfect Forward Security
  ssl_protocols TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4 !CBC";
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_session_cache    shared:SSL:10m;
  ssl_session_timeout  10m;
  EOT

