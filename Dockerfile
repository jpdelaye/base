# ---------- builder ----------
FROM composer:2 AS builder
WORKDIR /app

# 1) Crear CI4 AppStarter
RUN composer create-project codeigniter4/appstarter . --no-dev --prefer-dist

# 2) Instalar Shield
RUN composer require codeigniter4/shield --no-interaction --no-progress

# 3) Publicar archivos de Shield (si el comando cambia según versión, hacemos fallback)
RUN php spark shield:publish || php spark publish --namespace CodeIgniter\\Shield

# 4) Copiar overlay (multi-tenant + migraciones + filtros)
COPY docker/app-overlay/ /app/

# Optimizar autoloader
RUN composer dump-autoload -o


# ---------- runtime ----------
FROM php:8.3-apache
WORKDIR /var/www/html

# Extensiones comunes CI4 + MySQL
RUN apt-get update && apt-get install -y \
    libicu-dev libzip-dev unzip \
  && docker-php-ext-install intl mysqli pdo_mysql zip \
  && a2enmod rewrite headers \
  && rm -rf /var/lib/apt/lists/*

# Apache: DocumentRoot a /public
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# App
COPY --from=builder /app/ /var/www/html/

# Permisos para writable
RUN chown -R www-data:www-data /var/www/html/writable /var/www/html/public

# Entrypoint (migraciones al arrancar)
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]


