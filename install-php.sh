#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <PHP_version>"
  exit 1
fi

PHP_VERSION=$1
WEB_SERVER=${2:-"none"} # optional second argument

sudo apt update
sudo apt upgrade -y

# Add Ondrej PPAs if not already present
if ! grep -q "ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
  echo "Adding Ondrej PHP PPA..."
  sudo add-apt-repository ppa:ondrej/php -y
fi

if [ "$WEB_SERVER" = "apache2" ] && ! grep -q "ondrej/apache2" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
  echo "Adding Ondrej Apache2 PPA..."
  sudo add-apt-repository ppa:ondrej/apache2 -y
elif [ "$WEB_SERVER" = "nginx" ] && ! grep -q "ondrej/nginx" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
  echo "Adding Ondrej Nginx PPA..."
  sudo add-apt-repository ppa:ondrej/nginx -y
fi

sudo apt-get update

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <PHP_version>"
  exit 1
fi

PHP_VERSION=$1

# Add Ondrej PPA if not already present
if ! grep -q "ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
  echo "Adding Ondrej PPA..."
  sudo apt-get update
  sudo add-apt-repository ppa:ondrej/php -y
  sudo apt-get update
else
  echo "Ondrej PPA already present"
fi

# Install PHP packages
sudo apt-get install -y \
  "php${PHP_VERSION}-cli" \
  "php${PHP_VERSION}-common" \
  "php${PHP_VERSION}-mysql" \
  "php${PHP_VERSION}-zip" \
  "php${PHP_VERSION}-gd" \
  "php${PHP_VERSION}-mbstring" \
  "php${PHP_VERSION}-curl" \
  "php${PHP_VERSION}-xml" \
  "php${PHP_VERSION}-bcmath" \
  "php${PHP_VERSION}-dom" \
  "php${PHP_VERSION}-sqlite3"

# Only install json extension for PHP < 7.0 (bundled in 7.0+)
if (($(echo "$PHP_VERSION < 7.0" | bc -l))); then
  echo "Installing json extension for PHP ${PHP_VERSION}..."
  sudo apt-get install -y "php${PHP_VERSION}-json"
fi
