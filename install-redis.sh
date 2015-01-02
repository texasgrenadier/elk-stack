#!/bin/bash

# This script will download and install Redis.

echo "Installing Redis"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

wget -P /tmp/ http://dl.fedoraproject.org/pub/epel/6/x86_64/redis-2.4.10-1.el6.x86_64.rpm 
rpm -Uvh /tmp/redis-2.4.10-1.el6.x86_64.rpm

# Change bind address
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis.conf

service redis start
chkconfig redis on

echo "Redis Installed"
