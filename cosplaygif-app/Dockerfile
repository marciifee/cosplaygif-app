FROM php:8.3-fpm

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libpq-dev \
    zip \
    unzip \
    git \
    bash \
    curl \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install -j$(nproc) \
        fileinfo \
        dom \
        xml \
        simplexml
        gd \
        pdo \
        pdo_mysql \
        intl \
        mbstring \
        zip \
        exif \
        pcntl \
        bcmath \
        opcache

# Install Composer
#COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Application directory
WORKDIR /var/www/html

# Composer-Dateien zuerst (wichtig für Cache & Stabilität)
COPY composer.json composer.lock ./

# PHP Dependencies installieren
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-dev

# Copy the rest of the Laravel application
COPY . .

# Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

USER www-data

EXPOSE 9000
CMD ["php-fpm"]
