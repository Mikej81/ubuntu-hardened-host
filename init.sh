#!/bin/bash
echo ${nginx_repo_cert} >> /etc/ssl/nginx/nginx-repo.crt
echo ${nginx_repo_key} >> /etc/ssl/nginx/nginx-repo.key