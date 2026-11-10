FROM php:8.4-apache
# Instala o driver PDO usado pela API para acessar o MySQL.
RUN docker-php-ext-install pdo_mysql
COPY api.php /var/www/html/api.php
