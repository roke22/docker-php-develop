# Docker PHP Development Environment

Entorno de desarrollo Docker con Nginx, PostgreSQL, Redis y PHP con sincronización de usuarios y soporte para múltiples versiones de PHP.

## 🚀 Características

- 🐘 **PHP-FPM** con versiones flexibles (8.3, 8.2, 8.1, 8.0, 7.4, 7.3, 7.2, 7.1, 7.0)
- 🌐 **Nginx** como servidor web
- 🐘 **PostgreSQL** con persistencia de datos
- 🔴 **Redis** para caché y colas
- 👤 **Sincronización de usuario** entre host y contenedor (sin problemas de permisos)
- 🔌 **Compatible con VS Code Remote Containers**
- 📦 Soporte para hasta **3 proyectos simultáneos**

## 📋 Requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux/macOS (recomendado)

## 🛠️ Instalación

### 1. Crear volumen de PostgreSQL

```bash
docker volume create --name=postgres-data
```

### 2. Configurar variables de entorno

Ejecuta el script de configuración automática:

```bash
./setup-user.sh
```

O manualmente:

```bash
cp env-example .env
```

Edita el archivo `.env` y configura:

```env
# Rutas de tus proyectos (relativas o absolutas)
APP_CODE_FIRST_PROJECT=../tu-proyecto-1
APP_CODE_SECOND_PROJECT=../tu-proyecto-2
APP_CODE_THIRD_PROJECT=../tu-proyecto-3

# Versión de PHP (8.3, 8.2, 8.1, 8.0, 7.4, 7.3, 7.2, etc.)
PHP_VERSION=8.0

# Usuario sincronizado (obtén con: id -u e id -g)
USER_ID=1000
GROUP_ID=1000
```

### 3. Iniciar servicios

```bash
# Iniciar todos los servicios
docker-compose up -d

# O servicios específicos
docker-compose up -d nginx postgres redis php
```

### 4. Verificar que todo funciona

```bash
docker-compose ps
```

## 🔧 Configuración

### Cambiar versión de PHP

1. Edita el archivo `.env`:
   ```env
   PHP_VERSION=8.2  # Cambia a la versión deseada
   ```

2. Reconstruye el contenedor:
   ```bash
   docker-compose build php
   docker-compose up -d php
   ```

### Configurar Nginx

Edita el archivo `nginx/sites/site.conf` para configurar tus virtual hosts.

### Configuración de PostgreSQL

- **Host:** `postgres` (desde contenedores) o `localhost` (desde host)
- **Puerto:** `5432`
- **Base de datos:** `db`
- **Usuario:** `user`
- **Contraseña:** `password`

Puedes cambiar estas credenciales en el archivo `docker-compose.yml`.

### Configuración de Redis

- **Host:** `redis` (desde contenedores) o `localhost` (desde host)
- **Puerto:** `6379`

## 🔐 Configuración SSL (HTTPS)

El entorno soporta HTTPS para los dominios `dominio.roke.es`, `dominio2.roke.es` y `dominio3.roke.es`.

### 1. Generar certificados

Ejecuta el script de generación de certificados (requiere sudo para escribir en `nginx/ssl/` si fue creado por root):

```bash
sudo ./setup-ssl.sh
```

Reinicia Nginx para cargar los nuevos certificados:

```bash
docker-compose restart nginx
```

### 2. Confiar en el certificado en el navegador

Al ser certificados autofirmados, el navegador mostrará una advertencia de seguridad. Debes importar el certificado manualmente.

**Google Chrome / Chromium:**
1. Ve a `chrome://settings/certificates`
2. Pestaña **Autoridades** -> **Importar**
3. Selecciona `nginx/ssl/server.crt`
4. Marca **"Confiar en este certificado para identificar sitios web"**

**Firefox:**
1. Ajustes -> Privacidad y seguridad -> Certificados -> **Ver certificados**
2. Pestaña **Autoridades** -> **Importar**
3. Selecciona `nginx/ssl/server.crt`
4. Marca **"Confiar en esta CA para identificar sitios web"**

**Linux (Sistema):**
Para herramientas de línea de comandos (`curl`, etc.):
```bash
sudo cp ./nginx/ssl/server.crt /usr/local/share/ca-certificates/roke-dev.crt
sudo update-ca-certificates
```

## 📁 Estructura del Proyecto

```
.
├── docker-compose.yml      # Configuración de servicios
├── .env                     # Variables de entorno (no en git)
├── env-example              # Plantilla de variables
├── setup-user.sh            # Script de configuración automática
├── nginx/
│   ├── sites/
│   │   └── site.conf        # Configuración de virtual hosts
│   └── ssl/                 # Certificados SSL
├── postgres/
│   ├── Dockerfile
│   ├── configuration/
│   │   └── postgresql.conf  # Configuración de PostgreSQL
│   └── docker-entrypoint-initdb.d/  # Scripts de inicialización
├── redis/
│   ├── Dockerfile
│   └── configuracion/
│       └── redis.conf       # Configuración de Redis
└── php/
    └── Dockerfile           # Imagen PHP personalizada
```

## 💻 Uso con VS Code

### Conectar a contenedor PHP

1. Instala la extensión "Dev Containers" en VS Code
2. Abre la paleta de comandos (Ctrl+Shift+P)
3. Selecciona "Dev Containers: Attach to Running Container"
4. Elige el contenedor `develop-php-1`

### Extensiones PHP recomendadas

Dentro del contenedor, instala:
- PHP Intelephense
- PHP Debug
- PHP DocBlocker

## 🎯 Comandos Útiles

```bash
# Ver logs
docker-compose logs -f php
docker-compose logs -f nginx

# Reiniciar servicios
docker-compose restart php
docker-compose restart nginx

# Ejecutar comandos en PHP
docker-compose exec php php -v
docker-compose exec php composer install

# Acceder al shell del contenedor PHP
docker-compose exec php bash

# Parar servicios
docker-compose down

# Parar y eliminar volúmenes
docker-compose down -v
```

## 🐛 Solución de Problemas

### Problema: Permisos de archivos

**Solución:** Verifica que `USER_ID` y `GROUP_ID` en `.env` coincidan con tu usuario:

```bash
id -u  # Tu USER_ID
id -g  # Tu GROUP_ID
```

Luego reconstruye:

```bash
docker-compose build php
docker-compose up -d php
```

### Problema: Puerto ya en uso

**Solución:** Cambia los puertos en `docker-compose.yml`:

```yaml
ports:
  - "8080:80"   # En lugar de 80:80
  - "5433:5432" # En lugar de 5432:5432
```

### Problema: VS Code no puede conectar al contenedor

**Solución:** Asegúrate de que el contenedor PHP se construyó correctamente con el usuario:

```bash
docker-compose exec php whoami  # Debería mostrar 'devuser'
docker-compose exec php id      # Verifica UID y GID
```

### Problema: Base de datos vacía después de reiniciar

**Solución:** Verifica que el volumen existe:

```bash
docker volume ls | grep postgres-data
```

Si no existe, créalo:

```bash
docker volume create --name=postgres-data
docker-compose down
docker-compose up -d
```

## 🔐 Seguridad

⚠️ **Importante para producción:**

1. Cambia las credenciales por defecto de PostgreSQL
2. No expongas puertos innecesarios
3. Usa variables de entorno para credenciales sensibles
4. Configura SSL/TLS para Nginx
5. Mantén las imágenes actualizadas

## 📝 Licencia

Ver archivo [LICENSE](LICENSE)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## English Version

# Docker PHP Development Environment

Docker development environment with Nginx, PostgreSQL, Redis and PHP with user synchronization and support for multiple PHP versions.

## 🚀 Features

- 🐘 **PHP-FPM** with flexible versions (8.3, 8.2, 8.1, 8.0, 7.4, 7.3, 7.2, 7.1, 7.0)
- 🌐 **Nginx** web server
- 🐘 **PostgreSQL** with data persistence
- 🔴 **Redis** for cache and queues
- 👤 **User synchronization** between host and container (no permission issues)
- 🔌 **VS Code Remote Containers compatible**
- 📦 Support for up to **3 simultaneous projects**

## 📋 Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux/macOS (recommended)

## 🛠️ Installation

### 1. Create PostgreSQL volume

```bash
docker volume create --name=postgres-data
```

### 2. Configure environment variables

Run the automatic configuration script:

```bash
./setup-user.sh
```

Or manually:

```bash
cp env-example .env
```

Edit the `.env` file and configure:

```env
# Your project paths (relative or absolute)
APP_CODE_FIRST_PROJECT=../your-project-1
APP_CODE_SECOND_PROJECT=../your-project-2
APP_CODE_THIRD_PROJECT=../your-project-3

# PHP Version (8.3, 8.2, 8.1, 8.0, 7.4, 7.3, 7.2, etc.)
PHP_VERSION=8.0

# Synchronized user (get with: id -u and id -g)
USER_ID=1000
GROUP_ID=1000
```

### 3. Start services

```bash
# Start all services
docker-compose up -d

# Or specific services
docker-compose up -d nginx postgres redis php
```

### 4. Verify everything works

```bash
docker-compose ps
```

## 🔧 Configuration

### Change PHP version

1. Edit the `.env` file:
   ```env
   PHP_VERSION=8.2  # Change to desired version
   ```

2. Rebuild the container:
   ```bash
   docker-compose build php
   docker-compose up -d php
   ```

### Configure Nginx

Edit the `nginx/sites/site.conf` file to configure your virtual hosts.

### PostgreSQL Configuration

- **Host:** `postgres` (from containers) or `localhost` (from host)
- **Port:** `5432`
- **Database:** `db`
- **User:** `user`
- **Password:** `password`

You can change these credentials in the `docker-compose.yml` file.

### Redis Configuration

- **Host:** `redis` (from containers) or `localhost` (from host)
- **Port:** `6379`

## 💻 VS Code Usage

### Connect to PHP container

1. Install the "Dev Containers" extension in VS Code
2. Open command palette (Ctrl+Shift+P)
3. Select "Dev Containers: Attach to Running Container"
4. Choose the `develop-php-1` container

### Recommended PHP extensions

Inside the container, install:
- PHP Intelephense
- PHP Debug
- PHP DocBlocker

## 🎯 Useful Commands

```bash
# View logs
docker-compose logs -f php
docker-compose logs -f nginx

# Restart services
docker-compose restart php
docker-compose restart nginx

# Execute commands in PHP
docker-compose exec php php -v
docker-compose exec php composer install

# Access PHP container shell
docker-compose exec php bash

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## 🐛 Troubleshooting

### Issue: File permissions

**Solution:** Verify that `USER_ID` and `GROUP_ID` in `.env` match your user:

```bash
id -u  # Your USER_ID
id -g  # Your GROUP_ID
```

Then rebuild:

```bash
docker-compose build php
docker-compose up -d php
```

### Issue: Port already in use

**Solution:** Change ports in `docker-compose.yml`:

```yaml
ports:
  - "8080:80"   # Instead of 80:80
  - "5433:5432" # Instead of 5432:5432
```

### Issue: VS Code cannot connect to container

**Solution:** Make sure the PHP container was built correctly with the user:

```bash
docker-compose exec php whoami  # Should show 'devuser'
docker-compose exec php id      # Verify UID and GID
```

### Issue: Empty database after restart

**Solution:** Verify the volume exists:

```bash
docker volume ls | grep postgres-data
```

If it doesn't exist, create it:

```bash
docker volume create --name=postgres-data
docker-compose down
docker-compose up -d
```

## 🔐 Security

⚠️ **Important for production:**

1. Change default PostgreSQL credentials
2. Don't expose unnecessary ports
3. Use environment variables for sensitive credentials
4. Configure SSL/TLS for Nginx
5. Keep images updated

## 📝 License

See [LICENSE](LICENSE) file

## 🤝 Contributing

Contributions are welcome. Please:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


