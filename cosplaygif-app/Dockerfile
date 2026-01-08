FROM php:8.3-fpm

# ------------------------------------------------------------
# System dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    unzip \
    curl \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libpq-dev \
    libxml2-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# PHP extensions required by Laravel
# ------------------------------------------------------------
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
        opcache \
        ctype \
        tokenizer \
        curl \
        sodium

# ------------------------------------------------------------
# Composer
# ------------------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install Composer
#COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# ------------------------------------------------------------
# Application
# ------------------------------------------------------------
WORKDIR /var/www/html

COPY composer.json composer.lock ./

# Composer läuft jetzt mit allen benötigten Extensions
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-dev

COPY . .

# ------------------------------------------------------------
# Permissions
# ------------------------------------------------------------
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

USER www-data

EXPOSE 9000
CMD ["php-fpm"]
