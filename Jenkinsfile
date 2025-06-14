pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'marvinok26/devops-prac-docker1'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
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
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
                echo 'Docker image built successfully'
                sh "docker images | grep ${IMAGE_NAME}"
            }
        }
        
        stage('Test image') {
            steps {
                echo 'Testing Docker image...'
                sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} node --version"
                sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} ls -la"
                echo 'Image tests completed successfully'
            }
        }
        
        stage('Push image') {
            steps {
                echo 'Pushing image to DockerHub...'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${IMAGE_NAME}:latest"
                    echo "Successfully pushed ${IMAGE_NAME}:${IMAGE_TAG} and ${IMAGE_NAME}:latest"
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up local images...'
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
            sh "docker rmi ${IMAGE_NAME}:latest || true"
            sh 'docker system prune -f'
        }
        success {
            echo 'Pipeline completed successfully!'
            echo "Check your DockerHub: https://hub.docker.com/r/${IMAGE_NAME}"
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}