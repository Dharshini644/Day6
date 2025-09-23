pipeline {
    agent any

    environment {
        DOCKER_REPO = "docker.io/dharshini644/spring-boot-sample-gradle"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        CLUSTER_NAME = "spring-cluster"
        AWS_REGION = "ap-southeast-2"
        NAMESPACE = "sample-app-namespace"
        DEPLOYMENT_NAME = "sample-springboot-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Dharshini644/Day6.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-creds',
                                                      usernameVariable: 'DOCKERHUB_USER',
                                                      passwordVariable: 'DOCKERHUB_PASS')]) {
                        sh """
                        echo "🔨 Building Docker image..."
                        docker build -t ${DOCKER_REPO}:${IMAGE_TAG} .

                        echo "🔑 Logging in to Docker Hub..."
                        echo "\$DOCKERHUB_PASS" | docker login -u "\$DOCKERHUB_USER" --password-stdin

                        echo "📤 Pushing image to Docker Hub..."
                        docker push ${DOCKER_REPO}:${IMAGE_TAG}

                        echo "📌 Tagging and pushing 'latest'..."
                        docker tag ${DOCKER_REPO}:${IMAGE_TAG} ${DOCKER_REPO}:latest
                        docker push ${DOCKER_REPO}:latest
                        """
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-creds']]) {
                    sh """
                    echo "🔧 Updating kubeconfig..."
                    aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}

                    echo "🚀 Deploying to Kubernetes..."
                    kubectl set image deployment/${DEPLOYMENT_NAME} \
                        ${DEPLOYMENT_NAME}=${DOCKER_REPO}:${IMAGE_TAG} \
                        -n ${NAMESPACE} --record

                    echo "⏳ Waiting for rollout..."
                    kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE} --timeout=120s
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment succeeded: ${DOCKER_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Deployment failed — rolling back"
            sh "kubectl rollout undo deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}"
        }
    }
}
