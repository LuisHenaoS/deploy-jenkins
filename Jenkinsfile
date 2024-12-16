pipeline {
    agent any

    triggers {
        GenericTrigger(
            token: 'MYTOKEN',
            genericVariables: [
                [key: 'LOCALDEV_REF', value: '$.ref']
            ],
            causeString: 'Triggered on push from local-dev',
            printContributedVariables: true,
            printPostContent: true,
            regexpFilterText: '$LOCALDEV_REF',
            regexpFilterExpression: 'refs/heads/(develop|main)'
        )
    }

    environment {
        DOCKER_IMAGE = "proyecto/imagen"
    }

    stages {
        stage('Checkout local-dev') {
            steps {
                // Clonar el repo de local-dev en la rama env.LOCALDEV_BRANCH
                sh "git clone --branch ${env.LOCALDEV_BRANCH} https://github.com/LuisHenaoS/local-dev.git"
                sh "cd local-dev && ls -l"  // Debug
            }
        }

        stage('Install Dependencies') {
            steps {
                // Entrar a la carpeta clonada "local-dev"
                sh "cd local-dev && pip install --upgrade pip && pip install -r requirements.txt -r requirements-test.txt"
            }
        }

        stage('Lint') {
            steps {
                sh "cd local-dev && flake8 . --statistics --count"
            }
        }

        stage('Test') {
            steps {
                sh "cd local-dev && pytest --maxfail=1 --disable-warnings"
            }
        }

        stage('Build Docker') {
            steps {
                // Construir imagen Docker con la rama + build number, por ejemplo
                sh "cd local-dev && docker build -t ${DOCKER_IMAGE}:${env.LOCALDEV_BRANCH}-${env.BUILD_NUMBER} ."
            }
        }

        stage('Push Docker') {
            when {
                // Solo si es develop o main
                expression {
                    return (env.LOCALDEV_BRANCH == 'develop' || env.LOCALDEV_BRANCH == 'main')
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "docker login -u $USER -p $PASS"
                    sh "docker push ${DOCKER_IMAGE}:${env.LOCALDEV_BRANCH}-${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy Staging') {
            when {
                expression { env.LOCALDEV_BRANCH == 'develop' }
            }
            steps {
                sh "cd local-dev && bash deploy/deploy_staging.sh"
            }
        }

        stage('Deploy Production') {
            when {
                expression { env.LOCALDEV_BRANCH == 'main' }
            }
            steps {
                sh "cd local-dev && bash deploy/deploy_production.sh"
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}