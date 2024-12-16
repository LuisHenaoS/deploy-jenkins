pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "proyecto/imagen"
        REGISTRY = "docker.io"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/LuisHenaoS/local-dev.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install --upgrade pip'
                sh 'pip install -r requirements.txt -r requirements-test.txt'
            }
        }

        stage('Lint') {
            steps {
                sh 'flake8 . --statistics --count'
            }
        }

        stage('Test') {
            steps {
                sh 'pytest --maxfail=1 --disable-warnings'
            }
        }

        stage('Build Docker') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${env.GIT_COMMIT} ."
            }
        }

        stage('Push Docker') {
            when {
                branch pattern: "(develop|main)", comparator: "REGEXP"
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "docker login -u $USER -p $PASS"
                    sh "docker push ${DOCKER_IMAGE}:${env.GIT_COMMIT}"
                }
            }
        }

        stage('Deploy Staging') {
            when {
                branch 'develop'
            }
            steps {
                sh 'sh deploy/deploy_staging.sh'
            }
        }

        stage('Deploy Production') {
            when {
                branch 'main'
            }
            steps {
                sh 'sh deploy/deploy_production.sh'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
