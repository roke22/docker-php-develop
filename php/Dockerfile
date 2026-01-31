ARG PHP_VERSION=8.0
FROM php:${PHP_VERSION}-fpm

# Argumentos para configuración del usuario
ARG USER_ID=1000
ARG GROUP_ID=1000

# Instalar dependencias básicas
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Crear grupo y usuario con el UID/GID del host
RUN groupadd -g ${GROUP_ID} devuser && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash devuser

# Configurar permisos de directorios de trabajo
RUN mkdir -p /var/www/html /var/www/html2 /var/www/html3 && \
    chown -R devuser:devuser /var/www

# Cambiar al usuario no-root
USER devuser

WORKDIR /var/www/html

EXPOSE 9000
