#Plugins Installed
Docker Commons 
Docker Pipeline
Pipeline: Stage View 
Web for Blue Ocean
Distributed Workspace Clean
Snyk Security
Pipeline Utility Steps
SonarQube Scanner
OWASP Dependency-Check


#Configure Sonarqube
Tools -> Dependency->DP-Check->installation->automatic
Tools => SonarQube Scanner installations =>Add Sonarqube Scanner =>name=sonar-server
Systems->SonarQube installations->Name->sonar-server->Server authentication token->Sonar-token
Manage Jenkins → Configure System → SonarQube=> SonarQube installations=>  Name=> sonar-server => Server URL =>http://65.2.184.54:9000=> Server authentication token => Add - Select a  token or create a new token-> Sonarqube URL-> Administration-Configuration-> Security -> User -> Create a new token - Take token -> and create a secret in jenkins.
Administration=>Security=>Users=>create a token=>Sonar-token
Administration-Configuration->Webhooks->Create->Name->jenkins-sonar-webhoook->URL->http://65.2.137.252:8080/sonarqube-webhook

# Add secrets for Snyk Credentails Secret
#Link to generate token
https://app.snyk.io/account

# Snyk Credentials addition
manage -> credentials -> Global -> Add Credentials -> Secret text-> Secret ->  ID -> Snyk-Token -> Description -> Snyk-Token

#Add Docker Credentials as secret
manage -> credentials -> Global -> Add Credentials -> Username with password -> Username -> Password -> ID -> docker-creds -> Description -> docker-creds
#Setting sudo Permission for docker
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker jenkins
sudo systemctl restart docker
sudo systemctl restart jenkins

# installation of Snyk
# Install Node.js if not already installed
sudo apt update
sudo apt install -y nodejs npm
# Install Snyk using npm
npm install -g snyk

# Download the latest Snyk CLI binary
curl -Lo snyk "https://static.snyk.io/cli/latest/snyk-linux"
chmod +x snyk
sudo mv snyk /usr/local/bin
snyk --version

#Trivy installlation
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
trivy --version

# Trivy & Synk
/var/lib/jenkins/workspace/my-pipeline/
ls -al trivy-image-report.html
ls -al snyk-report.html
