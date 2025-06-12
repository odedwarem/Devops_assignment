pipeline {
  agent { //Creating agent to be able to use dotnet,docker, and kubectl in the pipeline
    kubernetes {
      inheritFrom 'jenkins-devops-agent'
      defaultContainer 'dotnet'
    }
  }

  environment { //Setting variables
    IMAGE_NAME = "dotnet-webapp"
    IMAGE_TAG = "v1"
    BUILD_OUTPUT = "myapp/bin/Release/net8.0/publish"
    NAMESPACE_PROD = "app-prod"
  }

  stages { 
    stage('Restore & Build .NET') { //Restores dependencies and publishes app. Runs inside dotnet container
      steps {
        container('dotnet') {
          sh 'dotnet restore myapp/myapp.csproj'
          sh 'dotnet publish myapp/myapp.csproj -c Release -o myapp/bin/Release/net8.0/publish'
        }
      }
    }

    stage('Docker Build') { //Buildes docker image based on the output. Runs inside docker container
      steps {
        container('docker') {
          sh """
            docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ${BUILD_OUTPUT}
            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
          """
        }
      }
    }

    stage('Deploy to PROD') { //Redeployes the app and exposes it. Runs inside kubectl container
      steps {
        container('kubectl') {
          sh """
            kubectl delete deployment ${IMAGE_NAME} -n ${NAMESPACE_PROD} --ignore-not-found
            kubectl create deployment ${IMAGE_NAME} --image=${IMAGE_NAME}:${IMAGE_TAG} -n ${NAMESPACE_PROD}
            kubectl expose deployment ${IMAGE_NAME} --port=80 --type=NodePort --name=${IMAGE_NAME}-service -n ${NAMESPACE_PROD}
          """
        }
      }
    }
  }
}
