# Script to set up Jenkins in Kubernetes
# This script creates all necessary resources for Jenkins

Write-Host "Creating devops namespace"
kubectl apply -f devops-namespace.yaml

Write-Host "Deploying Jenkins"
kubectl apply -f jenkins-deployment.yaml
kubectl apply -f jenkins-service.yaml

Write-Host "Jenkins Deployed successfully"

Write-Host "Creating production namespace"
kubectl apply -f app-prod-namespace.yaml

Write-Host "Give Jenkins role permissions"
kubectl apply -f jenkins-rbac.yaml
