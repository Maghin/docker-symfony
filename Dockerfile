FROM php:7.1-fpm

MAINTAINER MerhylStudio <maghin@merhylstudio.com>

LABEL description="Symfony Base Image"

ENV SYMFONY_ENV=prod

#=== Configure www-data user instead of default www-data user ===
ARG PHP_USER_UID=911
ARG PHP_USER_GID=911
ARG PHP_USER_NAME=www-data
ARG PHP_GROUP_NAME=www-data
RUN set -x \
  && groupmod -g ${PHP_USER_GID} -n ${PHP_GROUP_NAME} www-data \
  && usermod \
    -u ${PHP_USER_UID} \
    -g ${PHP_USER_GID} \
    -d /var/cache/nginx \
    -s /usr/sbin/nologin \
    -l ${PHP_USER_NAME} www-data

#=== Install zip php dependencie ===
RUN set -x \
  && buildDeps="zlib1g-dev" \
  && apt-get update && apt-get install -y ${buildDeps} \
  && docker-php-ext-install "zip" \
  && apt-get purge -y ${buildDeps} \
  && rm -rf /var/lib/apt/lists/*

#=== Install intl php dependencie ===
RUN set -x \
  && buildDeps="libicu-dev g++" \
	&& apt-get update && apt-get install -y ${buildDeps} \
	&& docker-php-ext-install "intl" \
	&& apt-get purge -y ${buildDeps} \
	&& runtimeDeps="libicu52" \
	&& apt-get install -y --auto-remove ${runtimeDeps} \
	&& rm -rf /var/lib/apt/lists/*

#=== Install xdebug ===
RUN set -x \
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
  } | tee -a $PHP_INI_DIR/xdebug.ini

#=== Install other runtime dependencies (git pdo_mysql) ===
RUN set -x \
  && runtimeDeps="git" \
  && apt-get update && apt-get install -y ${runtimeDeps} \
  && docker-php-ext-install "pdo_mysql" \
  && rm -rf /var/lib/apt/lists/*

#=== Install character set ===
ARG TIMEZONE=Europe/Paris
RUN set -x \
  && ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
  && echo ${TIMEZONE} > /etc/timezone \
  \
  && apt-get update && apt-get install -y locales \
  && sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && rm -rf /var/lib/apt/lists/*

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
