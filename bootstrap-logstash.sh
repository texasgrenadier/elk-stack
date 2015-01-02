#!/bin/bash
# This script will download, install and start the following items on RHEL 6.5:
# Logstash server 1.4.2
# Logstash web 1.4.2
# 
# This script should be safe to run more than one time.

# Install Elasticsearch
echo "Installing Elasticsearch"
cat << 'EOF' > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-1.4]
name=Elasticsearch repository for 1.4.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/1.4/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF

rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch
yum -y install elasticsearch

# Install Logstash
echo "Installing Logstash"
cat << 'EOF' > /etc/yum.repos.d/logstash.repo
[logstash-1.4]
name=logstash repository for 1.4.x packages
baseurl=http://packages.elasticsearch.org/logstash/1.4/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF

yum install -y logstash

# Install Kibana
echo "Installing Kibana"
wget -P /tmp/ http://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz
tar xvf /tmp/kibana-3.1.0.tar.gz; rm -f /tmp/kibana-3.1.0.tar.gz

if [ ! -d "/var/www" ]; then mkdir -p "/var/www"; fi
mv kibana-3.1.0/ /var/www/kibana3

# sed -i 's/"http:\/\/"+window.location.hostname+":9200"/"http:\/\/localhost:9200"/g' /var/www/kibana3/config.js
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

# Install the Elastic Search web interface
# /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head

# Install Redis
echo "Installing Redis"
wget -P /tmp/ http://dl.fedoraproject.org/pub/epel/6/x86_64/redis-2.4.10-1.el6.x86_64.rpm 
rpm -Uvh /tmp/redis-2.4.10-1.el6.x86_64.rpm

service redis start
chkconfig redis on

# Start the services
echo "Starting services (redis, elasticsearch, logstash, nginx)"
service redis start
chkconfig redis on

service elasticsearch start
chkconfig --add elasticsearch
chkconfig elasticsearch on

service logstash start
chkconfig logstash on

service nginx start
chkconfig nginx on

# APP_ROOT="/opt"
# ORIG_WKDIR=$(pwd)

# [ -f "$APP_ROOT" ] || mkdir -p $APP_ROOT

# # create logstash group
# if ! getent group logstash >/dev/null; then
#   groupadd -r logstash
# fi

# # create logstash user
# if ! getent passwd logstash >/dev/null; then
#   useradd -r -g logstash -d /opt/logstash -s /sbin/nologin -c "logstash" logstash
# fi

