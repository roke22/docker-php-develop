#!/bin/bash

# Script para configurar el archivo .env con el UID y GID del usuario actual

echo "Configurando sincronización de usuario para el contenedor PHP..."
echo ""

# Obtener UID y GID del usuario actual
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
CURRENT_USER=$(whoami)

echo "Usuario actual: $CURRENT_USER"
echo "UID: $CURRENT_UID"
echo "GID: $CURRENT_GID"
echo ""

# Verificar si existe el archivo .env
if [ -f .env ]; then
    echo "Actualizando archivo .env existente..."
    # Actualizar o agregar USER_ID
    if grep -q "^USER_ID=" .env; then
        sed -i "s/^USER_ID=.*/USER_ID=$CURRENT_UID/" .env
    else
        echo "USER_ID=$CURRENT_UID" >> .env
    fi
    
    # Actualizar o agregar GROUP_ID
    if grep -q "^GROUP_ID=" .env; then
        sed -i "s/^GROUP_ID=.*/GROUP_ID=$CURRENT_GID/" .env
    else
        echo "GROUP_ID=$CURRENT_GID" >> .env
    fi
else
    echo "Creando archivo .env desde env-example..."
    cp env-example .env
    sed -i "s/^USER_ID=.*/USER_ID=$CURRENT_UID/" .env
    sed -i "s/^GROUP_ID=.*/GROUP_ID=$CURRENT_GID/" .env
fi

echo ""
echo "✓ Configuración completada!"
echo ""
echo "Ahora ejecuta:"
echo "  docker-compose build php"
echo "  docker-compose up -d"
echo ""
echo "Para cambiar la versión de PHP, edita PHP_VERSION en .env"
echo "Ejemplos: 8.3, 8.2, 8.1, 8.0, 7.4, 7.3"
