#!/bin/bash
set -e

echo " Desplegando en Staging..."
docker pull luiishs/deployjenkins:${LOCALDEV_BRANCH}-${BUILD_NUMBER}
docker stop staging-container || true
docker rm staging-container || true
docker run -d --name staging-container -p 8081:80 luiishs/deployjenkins:${LOCALDEV_BRANCH}-${BUILD_NUMBER}
echo " Despliegue en Staging completado."