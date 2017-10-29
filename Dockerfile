FROM php:7.1-fpm-alpine

MAINTAINER MerhylStudio <maghin@merhylstudio.com>

LABEL description="Symfony Base Image"

ENV SYMFONY_ENV=prod

#=== Configure www-data user instead of default www-data user ===
ARG PHP_USER_UID=911
ARG PHP_USER_GID=911
ARG PHP_USER_NAME=www-data
ARG PHP_GROUP_NAME=www-data
RUN set -x \
  && echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && apk add --no-cache --virtual .build-deps shadow \
  && groupmod -g ${PHP_USER_GID} -n ${PHP_GROUP_NAME} www-data \
  && usermod \
    -u ${PHP_USER_UID} \
    -g ${PHP_USER_GID} \
    -d /var/cache/nginx \
    -s /usr/sbin/nologin \
    -l ${PHP_USER_NAME} www-data \
  && apk del .build-deps

#=== Install intl and zip php dependencie ===
RUN set -x \
  && apk add --no-cache \
    icu \
  && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    zlib-dev \
    icu-dev \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl \
  && docker-php-ext-enable intl \
  && docker-php-ext-install zip \
  && docker-php-ext-enable zip \
  && apk del .build-deps \
  && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

#=== Install xdebug ===
RUN set -x \
  && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
  && pecl install xdebug \
  && docker-php-ext-enable xdebug \
  && { \
    echo "error_reporting = E_ALL"; \
    echo "display_startup_errors = On"; \
    echo "display_errors = On"; \
    echo "xdebug.remote_enable=1"; \
    echo "xdebug.remote_connect_back=1"; \
    echo "xdebug.idekey=\"PHPSTORM\""; \
    echo "xdebug.remote_port=9001"; \
  } | tee -a $PHP_INI_DIR/xdebug.ini \
  && apk del .build-deps \
  && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

#=== Install pdo_mysql runtime dependencies ===
RUN set -x \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-enable pdo_mysql

#=== Setup the Composer installer ===
RUN set -x \
  && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=1.2.2 \
  && rm -f /tmp/composer-setup.*

#=== Setup Symfony installer ===
RUN set -x \
  && curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony \
  && chmod +x /usr/local/bin/symfony

#=== Configure php ===
RUN { \
    echo "date.timezone = Europe/Paris"; \
    echo "memory_limit = 64G"; \
    echo "expose_php = off"; \
    echo "display_errors = off"; \
    echo "register_globals = off"; \
    echo "allow_url_fopen = on"; \
    echo "short_open_tag = off"; \
    echo "post_max_size = 20M"; \
    echo "upload_max_filesize = 20M"; \
  } | tee "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/symfony
