#!/bin/bash

# This script will download, install and start Kibana.

echo "Installing Kibana"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

wget -P /tmp/ http://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz
tar xvf /tmp/kibana-3.1.0.tar.gz; rm -f /tmp/kibana-3.1.0.tar.gz

if [ ! -d "/var/www" ]; then mkdir -p "/var/www"; fi
mv kibana-3.1.0/ /var/www/kibana3

sed -i 's/hostname+":9200/hostname+":80/' /var/www/kibana3/config.js

cat << 'EOF' > /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
EOF

yum install -y nginx

rm /etc/nginx/conf.d/default.conf
cat << 'EOF' > /etc/nginx/conf.d/nginx.conf
#
# Nginx proxy for Elasticsearch + Kibana
#
# In this setup, we are password protecting the saving of dashboards. You may
# wish to extend the password protection to all paths.
#
# Even though these paths are being called as the result of an ajax request, the
# browser will prompt for a username/password on the first request
#
# If you use this, you'll want to point config.js at http://FQDN:80/ instead of
# http://FQDN:9200
#
server {
  listen                *:80 ;
  server_name           localhost;
  access_log            /var/log/nginx/kibana.access.log;
  location / {
    root  /var/www/kibana3;
    index  index.html  index.htm;
  }
  location ~ ^/_aliases$ {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
  location ~ ^/.*/_aliases$ {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
  location ~ ^/_nodes$ {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
  location ~ ^/.*/_search$ {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
  location ~ ^/.*/_mapping {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
  # Password protected end points
  # location ~ ^/kibana-int/dashboard/.*$ {
  #   proxy_pass http://127.0.0.1:9200;
  #   proxy_read_timeout 90;
  #   limit_except GET {
  #     proxy_pass http://127.0.0.1:9200;
  #     auth_basic "Restricted";
  #     auth_basic_user_file /etc/nginx/conf.d/kibana.myhost.org.htpasswd;
  #   }
  # }
  # location ~ ^/kibana-int/temp.*$ {
  #   proxy_pass http://127.0.0.1:9200;
  #   proxy_read_timeout 90;
  #   limit_except GET {
  #     proxy_pass http://127.0.0.1:9200;
  #     auth_basic "Restricted";
  #     auth_basic_user_file /etc/nginx/conf.d/kibana.myhost.org.htpasswd;
  #   }
  # }
}
EOF

service nginx start
chkconfig nginx on
