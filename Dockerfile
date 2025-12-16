# Usa la imagen base oficial de OpenLiteSpeed con PHP 8.1
FROM litespeedtech/openlitespeed:2.0.1-lsphp81

LABEL maintainer="Tu Nombre"

# Instalación de herramientas básicas y dependencias de PHP
RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        unzip \
        nano \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libonig-dev && \
    rm -rf /var/lib/apt/lists/*

# 1. Configurar y activar extensiones PHP comunes (ej. GD, Zip, Pdo-Mysql)
# El script lsphp_ext.sh facilita la instalación de extensiones PECL/natvas
RUN /usr/local/lsws/lsphp81/bin/pecl install redis && \
    /usr/local/lsws/lsphp81/bin/pecl install imagick && \
    /usr/local/lsws/lsphp81/bin/phpize && \
    docker-php-ext-install \
        zip \
        gd \
        exif \
        pdo_mysql \
        mysqli

# 2. Habilitar las extensiones en el php.ini
RUN echo "extension=redis.so" >> /usr/local/lsws/lsphp81/etc/php/8.1/litespeed/php.ini && \
    echo "extension=imagick.so" >> /usr/local/lsws/lsphp81/etc/php/8.1/litespeed/php.ini

# 3. Configuraciones específicas de OpenLiteSpeed
# Configuramos el virtual host por defecto para que apunte a /var/www/html (opcional)
# Aunque la imagen base ya configura /var/www/vhosts/localhost/html

# Exponer los puertos (ya están expuestos en la imagen base, pero se recomienda)
EXPOSE 80 443 7080

# Comando por defecto (la imagen base ya lo tiene)
CMD ["/usr/local/lsws/bin/litespeed", "-D"]
