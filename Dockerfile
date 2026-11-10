# Tiny File Manager++
#   docker build -t tinyfilemanagerplusplus .
#   docker run -d -p 8080:80 -v "$PWD/data:/var/www/html/data" -v "$PWD/tfm-config:/config" --name tfmpp tinyfilemanagerplusplus
# Users and settings are kept in /config/settings.php (TFMPP_SETTINGS), outside the web root.

FROM php:8.3-cli-alpine

RUN apk add --no-cache libzip-dev \
    && docker-php-ext-install zip

WORKDIR /var/www/html

COPY tinyfilemanager.php index.php

RUN mkdir -p /config /var/www/html/data
ENV TFMPP_SETTINGS=/config/settings.php

CMD ["php", "-S", "0.0.0.0:80"]
