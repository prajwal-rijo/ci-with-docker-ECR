pipeline {
  agent any


  environment {
    PROJECT_KEY = "maven-project"

    GROUP_ID    = "com.example"
    ARTIFACT_ID = "hello-devops"
    VERSION     = "1.0-SNAPSHOT"
    SONAR_HOST  = "http://3.95.65.192:9000"


    NEXUS_URL   = "98.93.74.236:8081"
    NEXUS_REPO  = "maven-snapshot"

    DEPLOY_DIR  = "/opt/app"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/prajwal-rijo/ci-with-artifact.git'
      }
    }

    stage('Build & Package') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
    }

    stage('Sonar Analysis') {
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

    

    stage('Upload Artifact to Nexus') {
      steps {
        nexusArtifactUploader(
  nexusVersion: 'nexus3',
  protocol: 'http',
  nexusUrl: "${NEXUS_URL}",
          repository: "${NEXUS_REPO}",
          credentialsId: 'nexus-creds',
          groupId: "${GROUP_ID}",
          version: "${VERSION}",
          artifacts: [
            [
              artifactId: "${ARTIFACT_ID}",
              classifier: '',
              file: "target/${ARTIFACT_ID}.war",
              type: 'war'
            ]
          ]
        )
      }
    }

    stage('Deploy on EC2 (Local)') {
      steps {
        sh '''
          mkdir -p ${DEPLOY_DIR}
cp target/${ARTIFACT_ID}.war ${DEPLOY_DIR}/${ARTIFACT_ID}.war
          echo "WAR copied to ${DEPLOY_DIR}"
        '''
      }
    }
  }

  post {
    success {
      echo "✅ FULL PIPELINE SUCCESSFUL"
    }
    failure {
      echo "❌ PIPELINE FAILED"
    }
  }
}
