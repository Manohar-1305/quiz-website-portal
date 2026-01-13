pipeline {
    agent any

    environment {
        VIRTUAL_ENV = '.venv'
        IMAGE_NAME  = 'quiz-web-app'
        IMAGE_TAG   = 'v1'
        SCANNER_HOME = '/opt/sonar-scanner'
        DOCKERHUB_USER   = 'manoharshetty507'
    }

    stages {

        stage('Checkout') {
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
                script {
                    sh '$VIRTUAL_ENV/bin/pip install -r requirements.txt || ls -l'
                    sh '$VIRTUAL_ENV/bin/pip install pytest'
                }
            }
        }

stage('OWASP FS Scan') {
    steps {
        dependencyCheck additionalArguments: '''
        --scan ./
        --exclude .venv
        --disableYarnAudit
        --disableNodeAudit
        --data /var/lib/jenkins/dependency-check-data
        ''',
        odcInstallation: 'DP-Check'

        dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
    }
}
        
        // Unit tests (NO database required)
        stage('Run Unit Tests') {
            steps {
                sh '''
                $VIRTUAL_ENV/bin/pytest -v -m "not integration"
                '''
            }
        }

        /*
        // Integration tests (REQUIRES database)
        stage('Run Integration Tests (DB)') {
            steps {
                sh '''
                $VIRTUAL_ENV/bin/pytest -v -m integration
                '''
            }
        }
        */

        stage('Debug Sonar Path') {
            steps {
                script {
                    sh 'echo "SONAR_SCANNER_HOME is: $SONAR_SCANNER_HOME"'
                    sh 'ls -l $SONAR_SCANNER_HOME/bin'
                }
            }
        }

       stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('sonar-server') {
            script {
                def scannerHome = tool name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                sh """
                ${scannerHome}/bin/sonar-scanner \
                -Dsonar.projectName=Flaskapp \
                -Dsonar.projectKey=Flaskapp
                """
            }
        }
    }
}



        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
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
            npx snyk-to-html -i snyk-report.json -o snyk-report.html
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
            $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG

            docker push $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG
            '''
          }
      }
    }
  }
}
