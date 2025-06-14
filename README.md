# .NET Web Application with Jenkins CI/CD

This project demonstrates a simple .NET Web API application with a complete CI/CD pipeline using Jenkins and Kubernetes.

## Prerequisites
- Docker Desktop
- Minikube
- kubectl
- Git
- .NET SDK 8.0
- PowerShell

## Project Structure
- `myapp/` - .NET Web API application
- `Jenkinsfile` - CI/CD pipeline configuration
- Kubernetes configuration files:
  - `jenkins-rbac.yaml` - Jenkins permissions
  - `jenkins-deployment.yaml` - Jenkins deployment
  - `jenkins-service.yaml` - Jenkins service
  - `devops-namespace.yaml` - DevOps namespace
  - `app-prod-namespace.yaml` - Production namespace
  - `jenkins-setup.ps1` - Setup script

## Setup Instructions

1. Start Minikube with Docker driver:
   ```bash
   minikube start --driver=docker
   ```

2. If PowerShell script execution is blocked, allow it:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

3. Run the Jenkins setup script:
   ```powershell
   .\jenkins-setup.ps1
   ```

4. Verify Jenkins deployment:
   ```bash
   kubectl get all -n devops
   kubectl get pods -n devops
   kubectl get service jenkins -n devops
   ```

5. Get Jenkins initial admin password:
   ```bash
   kubectl exec --namespace devops -it deploy/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
   ```

6. Access Jenkins:
   ```bash
   minikube service jenkins -n devops --url
   ```
   - Access the url from the result of the command
   - Use the password from step 5

## Jenkins Configuration

1. Install required plugins:
   - Docker Pipeline
   - Kubernetes CLI
   - Kubernetes

2. Configure Kubernetes Cloud:
   - Go to "Manage Jenkins" > "Clouds"
   - Click "New cloud" > "Kubernetes"
   - Configure the following settings:
     - Name: `kubernetes`
     - Kubernetes URL: `https://kubernetes.default.svc.cluster.local`
     - Kubernetes Namespace: `devops`
     - Credentials: none
     - Jenkins URL: `http://jenkins.devops.svc.cluster.local:8080/`
     - Jenkins tunnel: `jenkins.devops.svc.cluster.local:50000`
   - Save the configuration

3. Create a new pipeline:
   - Click "New Item"
   - Enter a name (e.g., "dotnet-webapp")
   - Select "Pipeline"
   - Click "OK"
   - In the pipeline configuration:
     - Select "Pipeline script from SCM"
     - Choose "Git" as SCM
     - Enter the repository URL
     - Set branch to `*/main`
     - Set script path to `Jenkinsfile`
     - Save the configuration

4. Executing the pipeline:
     - When the pipeline is created, click on `Build Now` and wait for the build to complete
     
## Application Access

After deployment, the application will be accessible at:
- Main endpoint: http://localhost:<NodePort>/
- To get the NodePort:
  ```bash
  kubectl get service dotnet-webapp-service -n app-prod
  ```

## Troubleshooting

1. If Jenkins pod is not ready:
   ```bash
   kubectl describe pod -n devops -l app=jenkins
   kubectl logs -n devops -l app=jenkins
   ```

2. If application is not accessible:
   ```bash
   kubectl get pods -n app-prod
   kubectl describe pod -n app-prod -l app=dotnet-webapp
   kubectl logs -n app-prod -l app=dotnet-webapp
   ```

3. To check service configuration:
   ```bash
   kubectl describe service dotnet-webapp-service -n app-prod
   ```

## Cleanup

To remove all resources:
```bash
kubectl delete namespace devops
kubectl delete namespace app-prod
minikube stop
```
