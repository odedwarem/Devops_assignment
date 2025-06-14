pipeline {
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
  serviceAccountName: jenkins
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
  - name: dotnet
    image: mcr.microsoft.com/dotnet/sdk:8.0
    command:
    - cat
    tty: true
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
  - name: docker
    image: docker:28.2.2-cli
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
  - name: kubectl
    image: lachlanevenson/k8s-kubectl:latest
    command:
    - cat
    tty: true
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
    }
  }

  environment { //Setting variables
    IMAGE_NAME = "dotnet-webapp"
    IMAGE_TAG = "${BUILD_NUMBER}"
    BUILD_OUTPUT = "myapp/bin/Release/net8.0/publish"
    NAMESPACE_PROD = "app-prod"
  }

  stages { 
    stage('Checkout') {
      steps {
        checkout scm  // This will checkout the code from the configured Git repository
      }
    }

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

    stage('Deploy to PROD') {
      steps {
        container('kubectl') {
          sh """
            kubectl delete deployment ${IMAGE_NAME} -n ${NAMESPACE_PROD} --ignore-not-found
            kubectl delete service ${IMAGE_NAME}-service -n ${NAMESPACE_PROD} --ignore-not-found
            kubectl create deployment ${IMAGE_NAME} --image=${IMAGE_NAME}:${IMAGE_TAG} -n ${NAMESPACE_PROD}
            kubectl expose deployment ${IMAGE_NAME} --port=80 --target-port=8080 --type=NodePort --name=${IMAGE_NAME}-service -n ${NAMESPACE_PROD}
          """
        }
      }
    }
  }
}
