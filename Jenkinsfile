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
        // Iniciamos LOCALDEV_BRANCH vacío; lo llenaremos más abajo
        LOCALDEV_BRANCH = ""
    }

    stages {
        stage('Parse branch') {
            steps {
                script {
                    // Convertir "refs/heads/main" en "main"
                    env.LOCALDEV_BRANCH = env.LOCALDEV_REF.replace("refs/heads/", "")
                    echo "LOCALDEV_BRANCH set to: ${env.LOCALDEV_BRANCH}"
                }
            }
        }

        stage('Checkout local-dev') {
            steps {
                sh "git clone --branch ${env.LOCALDEV_BRANCH} https://github.com/LuisHenaoS/local-dev.git"
                sh "cd local-dev && ls -l"
            }
        }

        stage('Install Dependencies') {
            steps {
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
                sh "cd local-dev && docker build -t ${DOCKER_IMAGE}:${env.LOCALDEV_BRANCH}-${env.BUILD_NUMBER} ."
            }
        }

        stage('Push Docker') {
            when {
                expression {
                    // Solo si env.LOCALDEV_BRANCH es 'develop' o 'main'
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
