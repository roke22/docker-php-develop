ARG PHP_VERSION=8.0
FROM php:${PHP_VERSION}-fpm

# Argumentos para configuración del usuario
ARG USER_ID=1000
ARG GROUP_ID=1000

# Instalar dependencias del sistema necesarias para los módulos de PHP
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libpq-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    libbz2-dev \
    libonig-dev \
    libsodium-dev \
    libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

# Configurar y instalar extensiones de PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        bz2 \
        calendar \
        exif \
        ftp \
        gd \
        gettext \
        intl \
        pcntl \
        pdo_pgsql \
        pgsql \
        shmop \
        soap \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        xsl \
        zip \
    && docker-php-ext-enable opcache

# Instalar Xdebug y Redis desde PECL
RUN pecl install xdebug redis \
    && docker-php-ext-enable xdebug redis

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Crear grupo y usuario con el UID/GID del host
RUN groupadd -g ${GROUP_ID} devuser && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash devuser

# Configurar permisos de directorios de trabajo
RUN mkdir -p /var/www/html /var/www/html2 /var/www/html3 && \
    chown -R devuser:devuser /var/www

# Cambiar al usuario no-root
USER devuser

# Instalar NVM y Node.js 24
ENV NVM_DIR /home/devuser/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install 24 \
    && nvm alias default 24 \
    && nvm use default

WORKDIR /var/www/html

EXPOSE 9000
