https://www.jenkins.io/doc/book/installing/linux/
#Install Java
sudo apt update
sudo apt install -y openjdk-21-jdk

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

# Enable & check Status
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins


# Install sonarqube
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts
