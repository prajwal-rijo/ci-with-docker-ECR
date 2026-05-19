pipeline {
    agent any

    environment {

        PROJECT_KEY = "maven-project"

        AWS_REGION = "us-east-1"

        IMAGE_NAME = "hello-devops"

        ECR_REPO = "933747314862.dkr.ecr.us-east-1.amazonaws.com/mydockerregistry"

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
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {

                    sh '''
                    mvn sonar:sonar \
                    -Dsonar.projectKey=${PROJECT_KEY} \
                    -Dsonar.projectName=${PROJECT_KEY} \
                    -Dsonar.host.url=${SONAR_HOST}
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {

                sh '''
                docker build -t ${IMAGE_NAME} .
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {

                sh '''
                docker tag ${IMAGE_NAME}:latest ${ECR_REPO}:latest
                '''
            }
        }

        stage('Login to AWS ECR') {
            steps {

                sh '''
                aws ecr get-login-password --region ${AWS_REGION} | \
                docker login --username AWS --password-stdin 975050024946.dkr.ecr.us-east-1.amazonaws.com
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            steps {

                sh '''
                docker push ${ECR_REPO}:latest
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {

                sh '''
                ssh -o StrictHostKeyChecking=no ${EC2_HOST} "

                docker pull ${ECR_REPO}:latest

                docker stop hello-devops-container || true

                docker rm hello-devops-container || true

                docker run -d \
                --name hello-devops-container \
                -p 8085:8080 \
                ${ECR_REPO}:latest
                "
                '''
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
    }
}
