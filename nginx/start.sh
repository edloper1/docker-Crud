#!/bin/sh
set -e

# Verificar que API_SERVICE_URL esté definida
if [ -z "$API_SERVICE_URL" ]; then
  echo "ERROR: API_SERVICE_URL no está definida"
  echo "Variables de entorno disponibles:"
  env | grep -i api || echo "Ninguna variable API encontrada"
  exit 1
fi

# Limpiar la URL (eliminar espacios y barras finales)
API_SERVICE_URL=$(echo "$API_SERVICE_URL" | sed 's/[[:space:]]*$//' | sed 's|/$||')

# Exportar la variable para que envsubst la pueda usar
export API_SERVICE_URL

# Mostrar la URL que se usará (útil para debugging)
echo "Configurando Nginx con API_SERVICE_URL: $API_SERVICE_URL"
echo "Longitud de la URL: ${#API_SERVICE_URL} caracteres"

# Verificar que la URL tenga el formato correcto
if ! echo "$API_SERVICE_URL" | grep -qE '^https?://'; then
  echo "ADVERTENCIA: La URL no parece tener protocolo (http:// o https://)"
fi

# Reemplazar variable de entorno en nginx.conf
# Usar envsubst con todas las variables que empiezan con API_SERVICE
envsubst '${API_SERVICE_URL}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Verificar que el archivo se creó correctamente
if [ ! -f /etc/nginx/conf.d/default.conf ]; then
  echo "ERROR: No se pudo crear el archivo de configuración"
  exit 1
fi

# Mostrar la configuración generada (útil para debugging)
echo "Configuración generada:"
cat /etc/nginx/conf.d/default.conf

# Verificar la configuración de nginx
echo "Verificando configuración de nginx..."
nginx -t

# Iniciar nginx en primer plano
echo "Iniciando nginx..."
exec nginx -g 'daemon off;'

