Tools -> Dependency->DP-Check->installation->automatic
Tools => SonarQube Scanner installations =>Add Sonarqube Scanner =>name=sonar-server
Systems->SonarQube installations->Name->sonar-server->Server authentication token->Sonar-token
Manage Jenkins → Configure System → SonarQube=> SonarQube installations=>  Name=> sonar-server => Server URL =>http://65.2.184.54:9000=> Server authentication token => Add - Select a  token or create a new token-> Sonarqube URL-> Administration-Configuration-> Security -> User -> Create a new token - Take token -> and create a secret in jenkins.
Administration=>Security=>Users=>create a token=>Sonar-token
Administration-Configuration->Webhooks->Create->Name->jenkins-sonar-webhoook->URL->http://65.2.137.252:8080/sonarqube-webhook
