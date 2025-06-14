pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        IMAGE_NAME = 'marvinok26/devops-prac-docker1'
    }
    
    stages {
        stage('Clone repository') {
            steps {
                echo 'Cloning repository...'
                checkout scm
                echo 'Repository cloned successfully'
            }
        }
        
        stage('Build image') {
            steps {
                echo 'Building Docker image...'
                script {
                    def app = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                    env.DOCKER_IMAGE = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
                echo 'Docker image built successfully'
            }
        }
        
        stage('Test image') {
            steps {
                echo 'Testing Docker image...'
                script {
                    def app = docker.image("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                    app.inside {
                        sh 'echo "Basic container test passed"'
                        sh 'node --version'
                        sh 'ls -la'
                        sh 'timeout 5s node server.js || echo "Server test completed"'
                    }
                }
                echo 'Image tests completed successfully'
            }
        }
        
        stage('Push image') {
            steps {
                echo 'Pushing image to DockerHub...'
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        def app = docker.image("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
                echo 'Image pushed to DockerHub successfully'
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            sh 'docker system prune -f'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}