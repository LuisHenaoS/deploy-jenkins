## Introducción


El repositorio deploy-jenkins contiene toda la configuración de Jenkins y scripts de automatización de intedración continua (CI) de la aplicación. Se asume que se integra con repositorios como local-dev y se basa en Webhooks de GitHub para ejecutar pipelines automatizados.

2. **Arquitectura de Software**

Nuestro pipeline Jenkins se compone de los siguientes componentes:

Jenkinsfile

Define stages: 
1. checkout de código (del repo local-dev)
2. linting (flake8) 
3. ejecución de test con pytest
4.  build de imagen Docker
5. push a DockerHub.


- **DockerHub**

Almacena la imagen resultante (luiishs/deployjenkins:<tag>).


**Jenkins y pipeline**

Jenkins se configura para escuchar Webhooks de GitHub ante cada push a main o develop.
Incluye stages de lint, test, build, push de la imagen resultante y posterior despliegue (opcional).



## **Pipeline Jenkins**

- Configuración

Se instala Jenkins y se agrega credencial DockerHub (docker-hub-creds).
Se habilita un token genérico si se usa Generic Webhook Trigger.

- Stages

1. Parse branch: Interpreta la rama (ej. refs/heads/main → main).

2. Install Dependencies: Instala Python packages para el lint y los tests.
    - Lint: Ejecuta flake8.
    - Test: Corre pytest.

3. Build Docker: Construye la imagen con la etiqueta ```DOCKER_IMAGE:branch-BUILD_NUMBER```

    - Push Docker: Empuja la imagen a DockerHub.
    - Deploy: (opcional) Llama scripts Ansible o CloudFormation que actualizan la infraestructura en AWS.


4. Estrategia de ramas
SGitflow: main, develop.

5. Jenkins triggers:

main → despliegues a producción o builds liberables.
develop → despliegues a entorno de pruebas/staging.
