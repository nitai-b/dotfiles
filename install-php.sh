#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <PHP_version>"
	exit 1
fi

PHP_VERSION=$1

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

if (($(echo "$PHP_VERSION >= 8" | bc -l))); then
	sudo apt-get install -y "php${PHP_VERSION}-json"
fi
