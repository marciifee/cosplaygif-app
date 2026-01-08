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
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Application
WORKDIR /var/www/html
COPY . .

# Permissions
RUN chown -R www-data:www-data /var/www/html

USER www-data

EXPOSE 9000
CMD ["php-fpm"]
