#!/bin/bash

# This script will download and install Elasticsearch.


echo "Installing Elasticsearch"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

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

if [ ! -d "/data" ]; then mkdir -p "/data"; fi
chown elasticsearch.elasticsearch /data
sed -i 's/#path.data: \/path\/to\/data1,\/path\/to\/data2/path.data: \/data/' /etc/elasticsearch/elasticsearch.yml

service elasticsearch start
chkconfig --add elasticsearch
chkconfig elasticsearch on

# Install the Elastic Search web interface
# /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head

echo "Elasticsearch installed"
