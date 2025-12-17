FROM php:8.3-apache

RUN a2enmod rewrite headers

# Extensiones comunes (mysqli / pdo_mysql para MariaDB)
RUN apt-get update && apt-get install -y \
    libzip-dev unzip \
  && docker-php-ext-install mysqli pdo_mysql zip \
  && rm -rf /var/lib/apt/lists/*

# Permite .htaccess (útil para frameworks tipo CI4/Laravel)
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf



