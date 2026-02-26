#!/bin/bash

# Directorio donde se guardarán los certificados
SSL_DIR="./nginx/ssl"

# Asegurarse de que el directorio existe
mkdir -p $SSL_DIR

# Generar clave privada y certificado autofirmado
# Validez de 365 días
# Nombres comunes (CN) y SANs configurados para localhost y dominios
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $SSL_DIR/server.key \
    -out $SSL_DIR/server.crt \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=Development/OU=IT/CN=dominio.roke.es" \
    -addext "subjectAltName=DNS:localhost,DNS:dominio.roke.es,DNS:dominio2.roke.es,DNS:dominio3.roke.es"

echo "Certificados generados en $SSL_DIR"
echo "  - $SSL_DIR/server.key"
echo "  - $SSL_DIR/server.crt"
