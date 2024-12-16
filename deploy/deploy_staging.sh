#!/bin/bash
set -e

echo " Desplegando en Staging..."
docker pull luiishs/deployjenkins:${GIT_COMMIT}
docker stop staging-container || true
docker rm staging-container || true
docker run -d --name staging-container -p 8080:80 luiishs/deployjenkins:${GIT_COMMIT}
echo " Despliegue en Staging completado."