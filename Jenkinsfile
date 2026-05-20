pipeline {
    agent any

    environment {
        PROJECT_KEY = "maven-project"
        AWS_REGION = "us-east-1"
        IMAGE_NAME = "hello-devops"
        IMAGE_TAG = "latest"
        ECR_REGISTRY = "933747314862.dkr.ecr.us-east-1.amazonaws.com"
        ECR_REPO = "${ECR_REGISTRY}/mydockerregistry"
        SONAR_HOST = "http://98.91.26.146:9000"
        EC2_HOST = "ubuntu@3.95.254.89"
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/prajwal-rijo/ci-with-docker-ECR.git'
            }
        }

        stage('Build WAR File') {
            steps {
                sh '''
                mvn clean package -DskipTests
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {

                    sh """
                    mvn sonar:sonar \
                    -Dsonar.projectKey=${PROJECT_KEY} \
                    -Dsonar.projectName=${PROJECT_KEY} \
                    -Dsonar.host.url=${SONAR_HOST}
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh """
                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Login to AWS ECR') {
            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {

                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    """
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh """
                docker push ${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to EC2') {
            steps {

                sshagent(['ec2-ssh-key']) {

                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds'
                    ]]) {

                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} '

                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_DEFAULT_REGION=${AWS_REGION}

                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REGISTRY}

                        docker pull ${ECR_REPO}:${IMAGE_TAG}

                        docker stop hello-devops-container || true

                        docker rm hello-devops-container || true

                        docker image prune -f || true

                        docker run -d \
                        --name hello-devops-container \
                        -p 8085:8080 \
                        ${ECR_REPO}:${IMAGE_TAG}

                        '
                        """
                    }
                }
            }
        }
    }

    post {

        success {
            echo '✅ FULL CI/CD PIPELINE SUCCESSFUL'
        }

        failure {
            echo '❌ PIPELINE FAILED'
        }

        always {
            sh 'docker system prune -f || true'
        }
    }
}

