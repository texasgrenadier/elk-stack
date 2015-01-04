#!/bin/bash

# This script will download and install Logstash.

# Install Logstash
echo "Installing Logstash"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

cat << 'EOF' > /etc/yum.repos.d/logstash.repo
[logstash-1.4]
name=logstash repository for 1.4.x packages
baseurl=http://packages.elasticsearch.org/logstash/1.4/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF

yum install -y logstash

cat << 'EOF' > /etc/logstash/conf.d/central.conf
input {
  redis {
    host => "127.0.0.1"
    # These settings should match the output of the agent
    data_type => "list"
    key => "logstash"

    # We use the 'json' codec here becaues we expect to read json events from the redis
    # codec => json
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }
  date {
    match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
  }
}

output {
  elasticsearch { 
    host => localhost
    protocol => "http" 
  }
}
EOF

service logstash start
chkconfig logstash on

echo "Logstash installed"
