# Stack symfony complet sur alpine

- Container `php:7-fpm-alpine` Application Symfony (worker php)
- Container `nginx:alpine` Application Symfony (web access)
- Container `mariadb:10.2` Base de données
- Container `phpmyadmin` Administration de la base de données
- Container `redis:alpine` Cache

## To run localy

Clone this [repository](https://github.com/Maghin/docker-symfony/) and `cd` to it.

    git clone git@github.com:Maghin/docker-symfony.git
    cd docker-symfony

Run docker-compose to start the full app on your system.

    docker-compose up

Go to your browser and try http://localhost:8080

## Containers

**MariaDB**

Docker image: mariadb:10.2

environment:
- MYSQL_ROOT_PASSWORD=iop
- MYSQL_DATABASE=symfony
- MYSQL_USER=symfony
- MYSQL_PASSWORD=symfony

volumes:
- ./volumes/mariadb:/var/lib/mysql
- ./initdb:/docker-entrypoint-initdb.d

**redis**

Docker image: redis:alpine

**phpmyadmin**

Docker image: phpmyadmin/phpmyadmin

ports: 8000

volumes:
- ./volumes/phpmyadmin:/sessions

**php**

Docker image: merhylstudio/symfony-php-fpm

volumes:
- ./symfony:/var/www/symfony

**nginx:**

Docker image: merhylstudio/symfony-nginx

ports: 8080

volumes_from:
- php
