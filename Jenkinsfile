pipeline {
    agent any

    environment {
        DOCKER_REPO = "docker.io/dharshini644/spring-boot-sample-gradle"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        CLUSTER_NAME = "spring"
        AWS_REGION = "ap-southeast-2"
        NAMESPACE = "sample-app-namespace"
        DEPLOYMENT_NAME = "sample-springboot-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-username/your-repo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry('', 'dockerhub-creds') {
                        def app = docker.build("${DOCKER_REPO}:${IMAGE_TAG}")
                        app.push()
                        // optional: also push "latest"
                        app.push("latest")
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-creds']]) {
                    sh """
                    aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}
                    kubectl set image deployment/${DEPLOYMENT_NAME} \
                        ${DEPLOYMENT_NAME}=${DOCKER_REPO}:${IMAGE_TAG} \
                        -n ${NAMESPACE} --record
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
