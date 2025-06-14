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
                    echo "Successfully logged in as ${DOCKER_USER}"
                    
                    // Push with retry logic for better reliability
                    script {
                        retry(3) {
                            echo "Attempting to push ${IMAGE_NAME}:${IMAGE_TAG}..."
                            sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                            echo "Successfully pushed ${IMAGE_NAME}:${IMAGE_TAG}"
                        }
                        
                        retry(3) {
                            echo "Attempting to push ${IMAGE_NAME}:latest..."
                            sh "docker push ${IMAGE_NAME}:latest"
                            echo "Successfully pushed ${IMAGE_NAME}:latest"
                        }
                    }
                    
                    echo "All images pushed successfully to DockerHub!"
                }
            }
        }
        
        stage('Verify Push') {
            steps {
                echo 'Verifying images were pushed successfully...'
                script {
                    // Quick verification that the push worked
                    sh "docker pull ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker pull ${IMAGE_NAME}:latest"
                    echo "Verification successful - images are available on DockerHub"
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up local images...'
            script {
                try {
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
                    sh "docker rmi ${IMAGE_NAME}:latest || true"
                    sh 'docker system prune -f || true'
                    echo 'Cleanup completed successfully'
                } catch (Exception e) {
                    echo "Cleanup failed: ${e.getMessage()}"
                }
            }
        }
        success {
            echo '🎉 Pipeline completed successfully!'
            echo "✅ Docker image built and tested"
            echo "✅ Images pushed to DockerHub"
            echo "🔗 Check your DockerHub: https://hub.docker.com/r/${IMAGE_NAME}"
            echo "📦 Image tags: ${IMAGE_TAG}, latest"
        }
        failure {
            echo '❌ Pipeline failed!'
            echo 'Common solutions:'
            echo '1. Check Docker daemon is running'
            echo '2. Verify DockerHub credentials'
            echo '3. Check network connectivity'
            echo '4. Review build logs above for specific errors'
        }
    }
}