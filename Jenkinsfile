pipeline {
  // Define the agent that will run the pipeline
  agent {
    kubernetes {
      label 'jenkins-agent'
      defaultContainer 'dotnet'
      namespace 'devops'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins-agent: jenkins-agent
spec:
  # Service account for Jenkins to interact with Kubernetes
  serviceAccountName: jenkins
  containers:
  # JNLP container for Jenkins agent communication
  - name: jnlp
    image: jenkins/inbound-agent:latest
  # Container for .NET SDK operations
  - name: dotnet
    image: mcr.microsoft.com/dotnet/sdk:8.0
    command:
    - cat
    tty: true
  # Container for Docker operations
  - name: docker
    image: docker:28.2.2-cli
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  # Container for Kubernetes operations
  - name: kubectl
    image: lachlanevenson/k8s-kubectl:latest
    command:
    - cat
    tty: true
  volumes:
  # Mount Docker socket for Docker operations
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
    }
  }

  // Define environment variables used in the pipeline
  environment { //Setting variables
    IMAGE_NAME = "dotnet-webapp"
    IMAGE_TAG = "${BUILD_NUMBER}"
    BUILD_OUTPUT = "myapp/bin/Release/net8.0/publish"
    NAMESPACE_PROD = "app-prod"
  }

  stages { 
    // Stage 1: Get the source code
    stage('Checkout') {
      steps {
        checkout scm  // This will checkout the code from the configured Git repository
      }
    }

    // Stage 2: Build the .NET application
    stage('Restore & Build .NET') { //Restores dependencies and publishes app. Runs inside dotnet container
      steps {
        container('dotnet') {
          dir('myapp') {
            sh 'dotnet restore'
            sh 'dotnet publish -c Release -o ../bin/Release/net8.0/publish'
          }
        }
      }
    }

    // Stage 3: Build the Docker image
    stage('Docker Build') { //Builds docker image based on the output. Runs inside docker container
      steps {
        container('docker') {
          sh """
            docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f myapp/Dockerfile myapp
            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
          """
        }
      }
    }

    // Stage 4: Deploy to production
    stage('Deploy to PROD') {
      steps {
        container('kubectl') {
          sh """
            # Delete existing deployment and service if they exist
            kubectl delete deployment ${IMAGE_NAME} -n ${NAMESPACE_PROD} --ignore-not-found
            kubectl delete service ${IMAGE_NAME}-service -n ${NAMESPACE_PROD} --ignore-not-found
            # Create new deployment with the latest image
            kubectl create deployment ${IMAGE_NAME} --image=${IMAGE_NAME}:${IMAGE_TAG} -n ${NAMESPACE_PROD}
            # Expose the deployment as a NodePort service
            kubectl expose deployment ${IMAGE_NAME} --port=8080 --target-port=8080 --type=NodePort --name=${IMAGE_NAME}-service -n ${NAMESPACE_PROD}
          """
        }
      }
    }
  }
}
