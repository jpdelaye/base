# ---------- Stage 1: Composer ----------
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress --optimize-autoloader

# ---------- Stage 2: PHP + Apache ----------
FROM php:8.3-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    libzip-dev zip unzip \
  && docker-php-ext-install pdo pdo_mysql mysqli \
  && a2enmod rewrite headers \
  && rm -rf /var/lib/apt/lists/*

# CI4: document root /public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
 && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# límites (ajusta si quieres)
RUN { \
  echo "upload_max_filesize=64M"; \
  echo "post_max_size=64M"; \
  echo "memory_limit=256M"; \
  echo "max_execution_time=120"; \
} > /usr/local/etc/php/conf.d/uploads.ini

WORKDIR /var/www/html
COPY . /var/www/html
COPY --from=vendor /app/vendor /var/www/html/vendor

# Permisos CI4
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 775 /var/www/html/writable

EXPOSE 80
CMD ["apache2-foreground"]
