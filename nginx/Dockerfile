FROM nginx:alpine

MAINTAINER MerhylStudio <maghin@merhylstudio.com>

#=== Configure www-data user instead of default nginx user ===
ARG NGINX_USER_UID=911
ARG NGINX_USER_GID=911
ARG NGINX_USER_NAME=www-data
ARG NGINX_GROUP_NAME=www-data
RUN set -x \
  && echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && apk add --no-cache --virtual .build-deps shadow \
  && groupmod -g ${NGINX_USER_GID} -n ${NGINX_GROUP_NAME} nginx \
  && usermod \
    -u ${NGINX_USER_UID} \
    -g ${NGINX_USER_GID} \
    -d /var/cache/nginx \
    -s /usr/sbin/nologin \
    -l ${NGINX_USER_NAME} nginx \
  && apk del .build-deps

#=== Remove default website ===
RUN rm -f /etc/nginx/conf.d/default.conf

#=== Add new Nginx configuration ===
COPY . /etc/nginx
