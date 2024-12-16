#!/bin/bash
set -e

echo "🚀 Desplegando en Staging..."
docker pull proyecto/imagen:${GIT_COMMIT}
docker stop staging-container || true
docker rm staging-container || true
docker run -d --name staging-container -p 8080:80 proyecto/imagen:${GIT_COMMIT}
echo "✅ Despliegue en Staging completado."