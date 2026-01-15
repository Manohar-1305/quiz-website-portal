# Jenkins CI/CD Setup with Security Tools and KIND Kubernetes

This repository documents the complete Jenkins setup used for CI/CD with Docker, SonarQube, Snyk, OWASP Dependency-Check, Trivy, and a KIND Kubernetes cluster that is reachable from other machines.

---

## Jenkins Plugins Installed

- Docker Commons  
- Docker Pipeline  
- Pipeline: Stage View  
- Web for Blue Ocean  
- Distributed Workspace Clean  
- Snyk Security  
- Pipeline Utility Steps  
- SonarQube Scanner  
- OWASP Dependency-Check  

---

## Jenkins System Configuration

### Add Jenkins User to sudoers
```bash
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jenkins
sudo chmod 440 /etc/sudoers.d/jenkins
sudo visudo -c
```
Docker Permissions
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker jenkins
sudo systemctl restart docker
sudo systemctl restart jenkins

SonarQube Configuration
Jenkins Tool Configuration

Manage Jenkins → Tools

Dependency-Check

Installation path: /opt/dependency-check

SonarQube Scanner

Name: sonar-server

SonarQube Server Setup

Manage Jenkins → Configure System → SonarQube

Name: sonar-server

Server URL: http://65.2.184.54:9000

Server authentication token: Sonar-token

Create SonarQube Token

SonarQube → Administration → Security → Users

Create token

Add token in Jenkins Credentials as Secret Text

SonarQube Webhook

SonarQube → Administration → Configuration → Webhooks

Name: jenkins-sonar-webhook

URL: http://65.2.137.252:8080/sonarqube-webhook

Snyk Configuration
Generate Snyk Token

https://app.snyk.io/account

Add Snyk Token to Jenkins

Manage Jenkins → Credentials → Global → Add Credentials

Kind: Secret Text

ID: Snyk-Token

Description: Snyk Token

Install Snyk CLI
sudo apt update
sudo apt install -y nodejs npm
npm install -g snyk


Alternative binary install:

curl -Lo snyk https://static.snyk.io/cli/latest/snyk-linux
chmod +x snyk
sudo mv snyk /usr/local/bin
snyk --version

Trivy Installation
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
trivy --version


Reports are generated under:

/var/lib/jenkins/workspace/my-pipeline/

OWASP Dependency-Check Installation
curl -fL https://github.com/jeremylong/DependencyCheck/releases/download/v9.0.10/dependency-check-9.0.10-release.zip -o dc.zip
sudo apt-get update
sudo apt-get install -y unzip
unzip dc.zip


Move to tool directory:

sudo mkdir -p /opt/dependency-check
sudo mv dependency-check/* /opt/dependency-check/


Verify:

ls /opt/dependency-check/bin/dependency-check.sh

Docker Credentials in Jenkins

Manage Jenkins → Credentials → Global → Add Credentials

Kind: Username with password

ID: docker-creds

Description: Docker credentials

KIND Kubernetes Cluster Setup
Create Cluster
kind create cluster --config kind-config

Get kubeconfig
kind get kubeconfig --name kind > kubeconfig

Update API Server IP

Edit kubeconfig and change:

server: https://3.108.227.150:6443

Add kubeconfig to Jenkins

Jenkins Dashboard → Manage Jenkins → Credentials

Select (global)
Add Credentials:
Kind: Secret file
File: kubeconfig
ID: kubeconfig-file

Description: KIND kubeconfig

Install kubectl on Jenkins Server
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

Verify Kubernetes Access
export KUBECONFIG=/root/config
kubectl get nodes

Notes

Jenkins requires restart after plugin and permission changes

Docker socket permissions are required for Jenkins pipelines

KIND API server is exposed via public IP for external access


---

This is **GitHub-ready**, readable, and professional.  
Paste → commit → done.

