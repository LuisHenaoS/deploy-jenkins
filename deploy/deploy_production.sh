#!/bin/bash
set -e

echo "🚀 Desplegando en Producción..."
docker pull proyecto/imagen:${GIT_COMMIT}
docker stop production-container || true
docker rm production-container || true
docker run -d --name production-container -p 8080:80 proyecto/imagen:${GIT_COMMIT}
echo "✅ Despliegue en Producción completado."