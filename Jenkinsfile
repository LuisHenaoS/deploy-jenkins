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

    stages {
        stage('Hello') {
            steps {
                echo "Hello from Jenkinsfile with GenericTrigger"
            }
        }
    }
}
