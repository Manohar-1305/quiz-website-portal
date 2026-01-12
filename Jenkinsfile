pipeline {
    agent any

    environment {
        VIRTUAL_ENV = '.venv'
        IMAGE_NAME  = 'quiz-web-app'
        IMAGE_TAG   = 'v1'
        SCANNER_HOME = '/opt/sonar-scanner'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Manohar-1305/quiz-website-portal.git'
            }
        }

        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Manohar-1305/quiz-website-portal.git'
            }
        }

        stage('Install python3-venv') {
            steps {
                sh '''
                sudo apt-get update
                sudo apt-get install -y python3-venv
                '''
            }
        }

        stage('Set Up Virtual Environment') {
            steps {
                sh '''
                python3 -m venv $VIRTUAL_ENV
                $VIRTUAL_ENV/bin/pip install --upgrade pip
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                $VIRTUAL_ENV/bin/pip install -r requirements.txt || true
                $VIRTUAL_ENV/bin/pip install pytest
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                $VIRTUAL_ENV/bin/pytest --disable-warnings -q || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                trivy image --format table \
                -o trivy-image-report.html \
                $IMAGE_NAME:$IMAGE_TAG || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-image-report.html', fingerprint: true
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                withCredentials([string(credentialsId: 'Snyk-Token', variable: 'SNYK_TOKEN')]) {
                    sh '''
                    snyk auth $SNYK_TOKEN
                    snyk container test $IMAGE_NAME:$IMAGE_TAG \
                    --severity-threshold=high \
                    --json > snyk-report.json || true

                    snyk-to-html -i snyk-report.json -o snyk-report.html
                    '''
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'snyk-report.html', fingerprint: true
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-creds',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                    echo $DOCKER_PASSWORD | docker login \
                    --username $DOCKER_USERNAME \
                    --password-stdin

                    docker tag $IMAGE_NAME:$IMAGE_TAG \
                    $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG

                    docker push $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deployment') {
            steps {
                sh '''
                kubectl set image deployment/quiz-app \
                quiz-app=$DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Prune Docker Images') {
            steps {
                sh '''
                docker system prune -af --volumes
                '''
            }
        }
    }
}
