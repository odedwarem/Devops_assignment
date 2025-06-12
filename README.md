# Devops_assignment
Steps:
1. make sure you have these app installed: Docker-desktop, minikube, kubectl, git, 
2. open powershell
3. start minikube using docker-desktop:
minikube start --driver=docker
4. initialize jenkins and namespaces in k8s using the config file
jenkins-setup.ps1
if powershell does not allow scripts, use this:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
5. (optional) check if jenkins in online
kubectl get all -n devops
kubectl get pods -n devops
kubectl get service jenkins -n devops
6. Get temporary password for jenkins login 
kubectl exec --namespace devops -it deploy/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
7. activate jenkins from container and get the url for the local computer to access jenkins
minikube service jenkins -n devops --url 
