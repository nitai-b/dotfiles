#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <PHP_version> [apache2|nginx] [composer]"
  echo ""
  echo "Examples:"
  echo "  $0 8.2                          # Install PHP 8.2 only"
  echo "  $0 8.2 apache2                  # Install PHP 8.2 with Apache2"
  echo "  $0 8.2 nginx                    # Install PHP 8.2 with Nginx"
  echo "  $0 8.2 none composer            # Install PHP 8.2 with Composer"
  echo "  $0 8.2 apache2 composer         # Install PHP 8.2, Apache2, and Composer"
  echo "  $0 8.2 nginx composer           # Install PHP 8.2, Nginx, and Composer"
  exit 1
fi

PHP_VERSION=$1
WEB_SERVER=${2:-"none"}
INSTALL_COMPOSER=${3:-"none"}

# Update system first
sudo apt-get update
sudo apt-get upgrade -y

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

# Only install json extension for PHP < 7.0
if (($(echo "$PHP_VERSION < 7.0" | bc -l))); then
  echo "Installing json extension for PHP ${PHP_VERSION}..."
  sudo apt-get install -y "php${PHP_VERSION}-json"
fi

# Install Apache2 if specified
if [ "$WEB_SERVER" = "apache2" ]; then
  if command -v apache2 &>/dev/null; then
    echo "Apache2 is already installed:"
    apache2 --version
  else
    echo "Installing Apache2 and PHP module..."
    sudo apt-get install -y apache2 "libapache2-mod-php${PHP_VERSION}"
    sudo a2enmod php${PHP_VERSION}
    sudo systemctl enable apache2
    sudo systemctl start apache2
    echo "Apache2 installed and started"
  fi
fi

# Install Nginx if specified
if [ "$WEB_SERVER" = "nginx" ]; then
  if command -v nginx &>/dev/null; then
    echo "Nginx is already installed:"
    nginx -v
  else
    echo "Installing Nginx and PHP FPM..."
    sudo apt-get install -y nginx "php${PHP_VERSION}-fpm"
    sudo systemctl enable nginx
    sudo systemctl start nginx
    sudo systemctl enable "php${PHP_VERSION}-fpm"
    sudo systemctl start "php${PHP_VERSION}-fpm"
    echo "Nginx and PHP FPM installed and started"
  fi
fi

# Check if Composer should be installed
if [ "$INSTALL_COMPOSER" = "composer" ]; then
  # Check if Composer is already installed
  if command -v composer &>/dev/null; then
    echo "Composer is already installed:"
    composer --version
    echo "Updating Composer to latest version..."
    sudo composer self-update
  else
    # Install Composer with hash verification
    echo "Installing Composer..."
    cd /tmp
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
    sudo php composer-setup.php
    sudo mv composer.phar /usr/local/bin/composer
    php -r "unlink('composer-setup.php');"
    cd -

    # Update to latest version
    sudo composer self-update

    # Verify Composer installation
    composer --version
  fi
fi

echo "PHP ${PHP_VERSION} setup complete!"
