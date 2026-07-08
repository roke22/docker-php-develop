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
    && nvm use default \
    && curl -fsSL https://claude.ai/install.sh | bash

# Directorio donde Claude Code CLI guarda las sesiones/chats.
# Se monta como volumen en docker-compose.yml para persistir entre reconstrucciones.
RUN mkdir -p /home/devuser/.claude

# ---------------------------------------------------------------------------
# Playwright / Chromium para los tests de navegador (Pest 4 + pest-plugin-browser)
# ---------------------------------------------------------------------------
# Fijamos la ruta de la caché de navegadores de forma explícita para que build y
# runtime usen exactamente la misma, y con el mismo usuario (devuser) que ejecuta
# los tests. Solo se montan como volumen /var/www/html y /home/devuser/.claude,
# así que /home/devuser/.cache NO queda sombreado: la caché persiste en la imagen.
ENV PLAYWRIGHT_BROWSERS_PATH=/home/devuser/.cache/ms-playwright

# Playwright global (fijado a la versión del proyecto para que la revisión de
# Chromium descargada coincida con la que espera playwright 1.61.1 en runtime).
RUN . "$NVM_DIR/nvm.sh" && nvm use default \
    && npm install -g playwright@1.61.1

# Dependencias de sistema (.so: libglib-2.0.so.0, libnss3, ...) como root.
# Delegamos en el propio Playwright (install-deps) para no mantener la lista a
# mano y, sobre todo, porque en Debian 13 (trixie, base de php:8.4-fpm) muchos
# paquetes cambiaron al sufijo t64 (libasound2t64, libatk1.0-0t64, ...) y una
# lista fija fallaría. install-deps resuelve los nombres correctos de la distro.
USER root
RUN apt-get update \
    && . "$NVM_DIR/nvm.sh" && nvm use default \
    && playwright install-deps chromium \
    && rm -rf /var/lib/apt/lists/*

# Binario de Chromium como devuser: la caché queda en
# /home/devuser/.cache/ms-playwright (mismo usuario que corre los tests).
USER devuser
RUN . "$NVM_DIR/nvm.sh" && nvm use default \
    && playwright install chromium

# Verificación en build: Chromium debe arrancar con todas las librerías presentes.
# (NODE_PATH apunta a los módulos globales para poder require('playwright')).
RUN . "$NVM_DIR/nvm.sh" && nvm use default \
    && NODE_PATH="$(npm root -g)" node -e "const {chromium}=require('playwright'); chromium.launch().then(b=>b.close()).then(()=>console.log('Playwright OK')).catch(e=>{console.error(e);process.exit(1)})"

WORKDIR /var/www/html

EXPOSE 9000
