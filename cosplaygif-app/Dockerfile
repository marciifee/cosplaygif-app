# Stage 1: Vendor (shared between all)
FROM composer:latest AS vendor
WORKDIR /app

# Install PHP extensions (needed for composer)
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions gd bcmath intl pcntl redis pdo_mysql

ARG SPARK_USERNAME
ARG SPARK_API_TOKEN
ENV SPARK_USERNAME=${SPARK_USERNAME}
ENV SPARK_API_TOKEN=${SPARK_API_TOKEN}

COPY composer.json composer.lock ./
#RUN composer config http-basic.spark.laravel.com "$SPARK_USERNAME" "$SPARK_API_TOKEN"
#RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts --no-progress

# Temporary Spark auth for private packages
RUN set -eux; \
    composer config --global http-basic.spark.laravel.com "$SPARK_USERNAME" "$SPARK_API_TOKEN"; \
    composer install --no-dev --prefer-dist --no-interaction --no-scripts --no-progress; \
    composer config --global --unset http-basic.spark.laravel.com; \
    rm -f /root/.composer/auth.json || true; \
    rm -f /app/.composer/auth.json || true; \
    rm -f /tmp/* /var/tmp/* || true

# Stage 2: Assets (build frontend with Node 22 + Yarn)
FROM node:22-alpine AS assets
WORKDIR /app

# Copy dependency manifests and install dependencies using Yarn (via Corepack)
COPY package.json yarn.lock ./
RUN corepack enable \
    && corepack prepare yarn@1.22.22 --activate \
    && yarn install --frozen-lockfile

# Copy only what is needed for building assets
COPY vite.config.js ./
COPY tailwind.config.js ./
COPY postcss.config.js ./
COPY resources ./resources
COPY public ./public

ENV NODE_ENV=production
RUN yarn build

# Stage 3: Worker image (CLI)
FROM php:8.4-cli-alpine AS worker
COPY --from=vendor /usr/local/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions bcmath intl pcntl gd curl pdo_mysql mbstring redis

ARG APP_ENV=production
WORKDIR /app
COPY . /app
COPY ".env.${APP_ENV:-production}" .env
COPY --from=vendor /app/vendor /app/vendor

RUN mkdir -p storage bootstrap/cache;
RUN chown -R www-data:www-data storage bootstrap/cache;
RUN chmod -R 775 storage bootstrap/cache;

USER www-data
CMD ["php", "artisan", "queue:work", "--tries=3", "--sleep=1"]

# Stage 4: FrankenPHP image (Web)
FROM dunglas/frankenphp:latest AS frankenphp
WORKDIR /app

ARG APP_ENV=production
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions bcmath intl pcntl gd curl pdo_mysql mbstring redis

COPY . /app
COPY ".env.${APP_ENV:-production}" .env
COPY --from=vendor /app/vendor /app/vendor

# Copy compiled frontend assets without installing Node/Yarn in this stage
COPY --from=assets /app/public/build /app/public/build

COPY --from=vendor /usr/local/bin/install-php-extensions /usr/local/bin/install-php-extensions
COPY --from=vendor /usr/bin/composer /usr/bin/composer

RUN mkdir -p storage bootstrap/cache;
RUN chown -R www-data:www-data storage bootstrap/cache;
RUN chmod -R 775 storage bootstrap/cache;

#EXPOSE 80
CMD ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=80"]