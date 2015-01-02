#!/bin/bash

# This script will download and install Java 1.7.0.

echo "Installing Java"

#java -version 2>&1 |  awk -F '"' '/version/ {print $2}'

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

yum -y install java-1.7.0-openjdk

echo "Java Installed"
