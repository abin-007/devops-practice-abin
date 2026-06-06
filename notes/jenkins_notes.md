following is the notes for the jenkins CICD pipeline which is implemented using the 

# JENKINS CI/CD Pipeline



# install the jenkins on the ec2 instance or the server

Inorder to write the pipeline , we need to select the add item  and select the pipeline 
-> we can write the code inside using the groovy script
-> one of the good way to write the pipeline is taking docker as  the agent

# how do we do that 
go to the dashboard o fthe Jenkins -> manage Jenkins -> plugins -> search docker plugin

——SONARQUBE-------
# install the sonarqube plugin
# install the sonarqube server on the vpc or ec2 instance
 follow the steps on the abhishek veeramalla

———DOCKER---------
# install docker on the ec2 instance or locally
-> sudo apt update
-> sudo apt installl   docker.io

# grant the permission to the users 
-> sudo su - (change to the root user)
-> usermod -aG  docker jenkins
-> usermod -aG docker ubuntu

# restart the system  or the  docker service 
-> systemctl restart docker


——ARGOCD———

———KUBERNETES——
# minikube start  —memory=4098  - - driver=hyperkit

what is the difference between the add user and user add
what is the difference between the mvn clean package and mvn clean install

what is the role of pom.xml 
-> it is responsible for getting dependencies runtime and building the applications