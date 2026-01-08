FROM php:8.3-fpm-alpine

# System dependencies
RUN apk add --no-cache \
    icu-dev \
    oniguruma-dev \
    libzip-dev \
    zlib-dev \
    git \
    unzip \
 && docker-php-ext-install \
    pdo \
    pdo_mysql \
    intl \
    mbstring \
    zip \
 && docker-php-ext-enable opcache


# PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    intl \
    mbstring \
    zip \
    opcache

WORKDIR /var/www

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy application
COPY . .

# Install dependencies
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]
