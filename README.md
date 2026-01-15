# Application Deployment – Steps and Configuration

This section documents the steps and configurations used to deploy the application using Jenkins CI/CD, Docker, Kubernetes (KIND), and Argo CD.

---

## Prerequisites Installed
- Install required plugins in Jenkins

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
- run on Jenkins Server

```bash
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jenkins && sudo chmod 440 /etc/sudoers.d/jenkins && sudo visudo -c
```
# Docker and Helm Installation
## Step 1: Install Docker

```bash
apt update
apt install docker.io -y
```
# Start and enable Docker:
``` bash
systemctl start docker
systemctl enable docker
```
# Setting sudo Permission for docker
```
sudo chmod 666 /var/run/docker.sock
```
# Install Helm for Installing argocd
```
snap install helm --classic
```
Verify Helm installation:
```
helm version
```
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
* Change the ip of Sonarqube Server IP
 
# Go to Sonarqube URL
Administration → Configuration → Security → User
Create a new token and store it in Jenkins

Administration → Security → Users
Create token = Sonar-token

Administration → Configuration → Webhooks
Name = jenkins-sonar-webhoook
URL = http://65.2.137.252:8080/sonarqube-webhook
* Change the ip of jenkins

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
```bash
vi kind-config

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

networking:
  apiServerAddress: "0.0.0.0"
  apiServerPort: 6443

kubeadmConfigPatches:
- |
  kind: ClusterConfiguration
  apiServer:
    certSANs:
      - "3.108.227.150"   # ← Add IP of NODE

nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30000
        hostPort: 30000
      - containerPort: 30001
        hostPort: 30001
      - containerPort: 30002
        hostPort: 30002
      - containerPort: 30003
        hostPort: 30003
      - containerPort: 30004
        hostPort: 30004
      - containerPort: 30005
        hostPort: 30005
      - containerPort: 30006
        hostPort: 30006
      - containerPort: 30007
        hostPort: 30007
      - containerPort: 30008
        hostPort: 30008
      - containerPort: 30009
        hostPort: 30009
      - containerPort: 30010
        hostPort: 30010
  - role: worker
  - role: worker
```
# Set the Cluster to the IP of Server
```
kubectl config set-cluster kind-multi-node-cluster   --server=https://3.108.227.150:6443
```
- Change the IP of the Kind Server
- 
# Get Kubeconfig
```
kind get kubeconfig --name multi-node-cluster
kind get kubeconfig --name multi-node-cluster > kubeconfig
```

# Change the IP to expose it to all
```bash
Change from 127.0.0.1 to:
server: https://3.108.227.150:6443
docker ps | grep control-plane
```
# Install kubectl on Jenkins server
```
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

# Get kubeconfig

On kind Server - save kubeconfig
```
export KUBECONFIG=/root/config
kubectl get nodes
```

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
# Install Argo CD CLI
```bash
curl -sSL -o argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/argocd
argocd version
```

