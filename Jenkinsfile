pipeline {
    agent any

    parameters {
        string(name: 'LOCALDEV_REF', defaultValue: '', description: 'Branch ref from webhook')
    }

    triggers {
        GenericTrigger(
            token: 'MYTOKEN',
            genericVariables: [
                [key: 'LOCALDEV_REF', value: '$.ref'] // webhook JSON $.ref => "refs/heads/main"
            ],
            causeString: 'Triggered on push from local-dev',
            printContributedVariables: true,
            printPostContent: true,
            regexpFilterText: '$LOCALDEV_REF',
            regexpFilterExpression: 'refs/heads/(develop|main)'
        )
    }

    environment {
        DOCKER_IMAGE = 'proyecto/imagen'
    // Inicializamos LOCALDEV_BRANCH vacio, lo llenaremos mas abajo
    }

    stages {
        stage('Parse branch') {
            steps {
                script {
                    // Muestra lo que recibe el parámetro
                    echo "DEBUG Webhook variable -> params.LOCALDEV_REF = [${params.LOCALDEV_REF}]"

                    def ref = params.LOCALDEV_REF
                    if (!ref) {
                        // Valor por defecto
                        ref = 'refs/heads/main'
                        echo "LOCALDEV_REF no estaba definido. Usando valor por defecto: ${ref}"
                    }

                    // Convertimos "refs/heads/main" a "main"
                    def branchName = ref.replace('refs/heads/', '')
                    echo "LOCALDEV_BRANCH calculado: ${branchName}"

                    // Guardamos en env.* para usarlo en las siguientes stages
                    env.LOCALDEV_REF = ref
                    env.LOCALDEV_BRANCH = branchName
                }
            }
        }

        stage('Checkout local-dev') {
            steps {
                echo "Clonando la rama: ${env.LOCALDEV_BRANCH}"
                sh """
                    git clone --branch ${env.LOCALDEV_BRANCH} https://github.com/LuisHenaoS/local-dev.git
                    cd local-dev && ls -l
                """
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    cd local-dev
                    pip install --upgrade pip
                    pip install -r requirements.txt -r requirements-test.txt
                '''
            }
        }

        stage('Lint') {
            steps {
                sh 'cd local-dev && flake8 . --statistics --count'
            }
        }

        stage('Test') {
            steps {
                sh 'cd local-dev && pytest --maxfail=1 --disable-warnings'
            }
        }

        stage('Build Docker') {
            steps {
                sh """
                    cd local-dev
                    docker build -t ${DOCKER_IMAGE}:${env.LOCALDEV_BRANCH}-${env.BUILD_NUMBER} .
                """
            }
        }

        stage('Push Docker') {
            when {
                expression { env.LOCALDEV_BRANCH == 'develop' || env.LOCALDEV_BRANCH == 'main' }
            }
            steps {
                /* groovylint-disable-next-line LineLength */
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        docker login -u $USER -p $PASS
                        docker push ${DOCKER_IMAGE}:${env.LOCALDEV_BRANCH}-${env.BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Deploy Staging') {
            when {
                expression { env.LOCALDEV_BRANCH == 'develop' }
            }
            steps {
                sh 'cd local-dev && bash deploy/deploy_staging.sh'
            }
        }

        stage('Deploy Production') {
            when {
                expression { env.LOCALDEV_BRANCH == 'main' }
            }
            steps {
                sh 'cd local-dev && bash deploy/deploy_production.sh'
            }
        }
        stage('Debug environment') {
            steps {
                sh 'printenv | sort'
                script {
                    echo "params: ${params}"
                }
            }
        }
    }

    post {
        always {
            echo 'Limpiando el workspace...'
            cleanWs()
        }
    }
}
