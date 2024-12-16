#!/bin/bash
set -e

echo " Desplegando en Produccion..."
docker pull luiishs/deployjenkins:${LOCALDEV_BRANCH}-${BUILD_NUMBER}
docker stop production-container || true
docker rm production-container || true
docker run -d --name production-container -p 8080:80 luiishs/deployjenkins:${LOCALDEV_BRANCH}-${BUILD_NUMBER}
echo "Despliegue en Producción completado."