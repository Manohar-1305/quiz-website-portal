# Plugins Installed

Docker Commons  
Docker Pipeline  
Pipeline: Stage View  
Web for Blue Ocean  
Distributed Workspace Clean  
Snyk Security  
Pipeline Utility Steps  
SonarQube Scanner  
OWASP Dependency-Check  

---

# Adding Jenkins to sudoers

```bash
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jenkins && sudo chmod 440 /etc/sudoers.d/jenkins && sudo visudo -c
```

# Setting sudo Permission for docker
sudo chmod 666 /var/run/docker.sock

# Configure OSWAP Dependency
Tools -> Dependency -> DP-Check -> Install automatically-> Install from github.com -> Version latest

# Configure Sonarqube
Tools => SonarQube Scanner installations
Add Sonarqube Scanner
Name = sonar-server

Systems -> SonarQube installations
Name = sonar-server
Server authentication token = Sonar-token

Manage Jenkins → Configure System → SonarQube
SonarQube installations
Name = sonar-server
Server URL = http://65.2.184.54:9000
Server authentication token = Sonar-token

Sonarqube URL
Administration → Configuration → Security → User
Create a new token and store it in Jenkins

Administration → Security → Users
Create token = Sonar-token

Administration → Configuration → Webhooks
Name = jenkins-sonar-webhoook
URL = http://65.2.137.252:8080/sonarqube-webhook

# Installation of Snyk
Install Node.js if not already installed
```bash
sudo apt update
sudo apt install -y nodejs npm
Install Snyk using npm
npm install -g snyk
```
# Download the latest Snyk CLI binary
```bash
curl -Lo snyk "https://static.snyk.io/cli/latest/snyk-linux"
chmod +x snyk
sudo mv snyk /usr/local/bin
snyk --version
```

# Add secrets for Snyk Credentials Secret
Link to generate token
https://app.snyk.io/account

# Snyk Credentials addition
Manage Jenkins → Credentials → Global → Add Credentials

Secret text
ID = Snyk-Token
Description = Snyk-Token

# Add Docker Credentials as secret
Manage Jenkins → Credentials → Global → Add Credentials

Username with password
ID = docker-creds
Description = docker-creds

#Setting sudo Permission for docker
```bash
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker jenkins
sudo systemctl restart docker
sudo systemctl restart jenkins
```
# Trivy Installation
```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
trivy --version
```
# Check Trivy & Snyk report after running pipeline
```bash
cd /var/lib/jenkins/workspace/my-pipeline/
ls -al trivy-image-report.html
```
# Add kubeconfig in Jenkins

Steps to Add kubeconfig in Jenkins
Jenkins Dashboard->Manage Jenkins->Credentials->(global) domain->Add Credentials
Kind = Secret file
Upload kubeconfig file
ID = kubeconfig-file
Description = Kubernetes kubeconfig for KIND cluster

# Create a Kind Cluster
kind create cluster --config kind-config

# Get Kubeconfig
kind get kubeconfig --name multi-node-cluster
kind get kubeconfig --name multi-node-cluster > kubeconfig

# Change the IP to expose it to all
```bash
Change from 127.0.0.1 to:
server: https://3.108.227.150:6443
docker ps | grep control-plane
```
# Install kubectl on Jenkins server
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Get kubeconfig

On kind Server - save kubeconfig
export KUBECONFIG=/root/config
kubectl get nodes

# Argo CD Installation (NodePort)

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

# Create a namespace
```bash
kubectl create namespace argocd
```

# Create a values.yaml for argocd
```bash
cat <<EOF > argocd-values.yaml
server:
  insecure: true
  service:
    type: NodePort
    nodePortHttp: 30004
    nodePortHttps: null
EOF
```
# Helm install argocd
```bash
helm install argocd argo/argo-cd -n argocd -f argocd-values.yaml
```

# Check Pod & Svc
```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
kubectl get svc argocd-server -n argocd

```
# Get the admin password
``` bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```
Install Argo CD CLI
```bash
curl -sSL -o argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/argocd
argocd version
```

