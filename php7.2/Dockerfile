FROM php:7.2-apache

ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=1000

RUN  a2enmod rewrite \
  && a2enmod headers \
  && apt-get update && apt-get install -y \
        unzip \
        git \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        zlib1g-dev libicu-dev g++ \
        libc-client-dev \
        libkrb5-dev \
        libmagickwand-dev \
  && rm -r /var/lib/apt/lists/* \
  && docker-php-ext-install pdo_mysql mysqli \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install bcmath \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl \
  && docker-php-ext-install -j$(nproc) gd \
  && yes | pecl install imagick \
  && docker-php-ext-enable imagick \
  && docker-php-ext-install zip \
  && groupmod -g ${HOST_GROUP_ID} www-data \
  && usermod -u ${HOST_USER_ID} www-data \
  && chown -R www-data:www-data /var/www/html

