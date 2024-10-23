pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'your-dockerhub-username/flask_app'
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        DEPLOYMENT_SERVER_NONPROD = 'your-non-prod-server'
        DEPLOYMENT_SERVER_PROD = 'your-prod-server'
        BRANCH_NAME = "${env.GIT_BRANCH}"  // Capture the current branch
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }
        stage('Run Unit Tests in Jenkins') {
            steps {
                sh 'pytest tests/test_unit.py --maxfail=5 --disable-warnings'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_HUB_REPO}:${BUILD_NUMBER} .'
                }
            }
        }
        stage('Run Integration Tests in Docker') {
            steps {
                script {
                    sh 'docker-compose -f docker-compose.test.yml up --abort-on-container-exit'
                }
            }
        }
        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                        sh 'docker push ${DOCKER_HUB_REPO}:${BUILD_NUMBER}'
                    }
                }
            }
        }
        stage('Deploy to Non-Prod or Prod') {
            steps {
                script {
                    // Deploy to Non-Prod if on the non-prod branch
                    if (BRANCH_NAME == 'origin/non-prod') {
                        sshagent(['your-ssh-credentials']) {
                            sh """
                                ssh -o StrictHostKeyChecking=no user@${DEPLOYMENT_SERVER_NONPROD} \
                                'docker pull ${DOCKER_HUB_REPO}:${BUILD_NUMBER} && \
                                docker stop flask_app || true && \
                                docker rm flask_app || true && \
                                docker run -d --name flask_app -p 5000:5000 ${DOCKER_HUB_REPO}:${BUILD_NUMBER}'
                            """
                        }
                    }
                    // Deploy to Prod if on the prod branch
                    else if (BRANCH_NAME == 'origin/prod') {
                        sshagent(['your-ssh-credentials']) {
                            sh """
                                ssh -o StrictHostKeyChecking=no user@${DEPLOYMENT_SERVER_PROD} \
                                'docker pull ${DOCKER_HUB_REPO}:${BUILD_NUMBER} && \
                                docker stop flask_app || true && \
                                docker rm flask_app || true && \
                                docker run -d --name flask_app -p 5000:5000 ${DOCKER_HUB_REPO}:${BUILD_NUMBER}'
                            """
                        }
                    } else {
                        error("This branch is not configured for deployment.")
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
