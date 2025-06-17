FROM php:8.2-fpm

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y \
    git curl zip unzip supervisor \
    libonig-dev libxml2-dev libpng-dev libjpeg-dev \
    libfreetype6-dev libzip-dev nodejs npm \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl sockets

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece directorio de trabajo
WORKDIR /var/www

# Copia el proyecto
COPY . .

# Instala dependencias PHP y JS
RUN composer install --no-dev --optimize-autoloader \
    && npm install && npm run build

# Establece permisos
RUN chown -R www-data:www-data storage bootstrap/cache

# Copia la configuración de supervisor
COPY ./supervisord.conf /etc/supervisord.conf

# Expone puertos Laravel (8000) y Reverb (6001)
EXPOSE 8000 6001

# Inicia ambos procesos
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
