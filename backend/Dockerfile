FROM php:8.3-apache

WORKDIR /var/www/html

RUN a2enmod rewrite

COPY . /var/www/html/

RUN mkdir -p /var/www/html/uploads \
    && chown -R www-data:www-data /var/www/html/uploads \
    && chmod -R 775 /var/www/html/uploads

EXPOSE 80