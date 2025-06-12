Write-Host "Creating devops namespace"
kubectl apply -f devops-namespace.yaml

Write-Host "Deploying Jenkins"
kubectl apply -f jenkins-deployment.yaml
kubectl apply -f jenkins-service.yaml

Write-Host "Jenkins Deployed successfully"