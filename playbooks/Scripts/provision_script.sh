#!/bin/bash

echo "===> ADD REPOSITORY FOR JENKINS"
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    
    echo "===> UPDATE REPOSITORY"
    sudo apt-get update

    echo "===> INSTALL JAVA 8"
    sudo apt-get -y install openjdk-8-jdk
    echo "===> INSTALL GIT"
    sudo apt-get -y install git
    echo "===> INSTALL HTTPING"
    sudo apt-get -y install httping
    echo "===> INSTALL MAVEN"
    sudo mkdir ~/distr
    cd ~/distr
    sudo wget http://apache-mirror.rbc.ru/pub/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz
    tar xvf apache-maven-3.5.2-bin.tar.gz -C /opt/
    
    PATH=/opt/apache-maven-3.5.2/bin:$PATH
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
    M3_HOME=/opt/apache-maven-3.5.2/
    echo "===> INSTALL JENKINS"
    sudo apt-get -y install jenkins
    echo "===> JENKINS CONFIGURATION"
    sudo sed -i s/HTTP_PORT=8080/HTTP_PORT=8081/g /etc/default/jenkins
    sudo sed -i s/-Djava.awt.headless=true/'-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false'/g /etc/default/jenkins
    sudo echo "jenkins ALL=(ALL:ALL) ALL \n\
jenkins ALL = NOPASSWD: /bin/cp, /bin/mkdir, /bin/kill, /usr/bin/xargs, /usr/bin/pgrep" >> /etc/sudoers
    sudo sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/' /var/lib/jenkins/config.xml    

sudo sed -i '/<authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">/d' /var/lib/jenkins/config.xml

sudo sed -i '/<denyAnonymousReadAccess>true<\/denyAnonymousReadAccess>/d' /var/lib/jenkins/config.xml
sudo sed -i '/<\/authorizationStrategy>/d' /var/lib/jenkins/config.xml

    sudo systemctl restart jenkins.service
    while ! httping -qc1 http://127.0.0.1:8081 ; do sleep 15; echo "===> WAIT UNTIL JENKIS STARTS"; done
    cd /var/lib/jenkins
    sudo wget http://127.0.0.1:8081/jnlpJars/jenkins-cli.jar
    echo "===> INSTALLING PLUGINS"
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin build-pipeline-plugin
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin build-timeout
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin build-timeout
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin email-ext
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin github-branch-source
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin gitlab-plugin
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin gradle
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin jenkins-multijob-plugin
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin openshift-pipeline
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin workflow-aggregator
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin pipeline-maven
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin pipeline-github-lib
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin pipeline-multibranch-defaults
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin rebuild
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin ssh
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin ssh-slaves
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin timestamper
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ install-plugin ws-cleanup
    sudo sed -i 's/<jdks\/>/<jdks><jdk><name>jenkins_jdk<\/name><home>\/usr\/lib\/jvm\/java-8-openjdk-amd64\/<\/home><properties\/><\/jdk><\/jdks>/g' /var/lib/jenkins/config.xml
sudo cp /tmp/hudson.tasks.Maven.xml /var/lib/jenkins/hudson.tasks.Maven.xml
    
    sudo systemctl restart jenkins.service
    while ! httping -qc1 http://localhost:8081 ; do sleep 15; echo echo "===> WAIT UNTIL JENKIS STARTS"; done
    java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ create-job Spring_Petclinic_Pipeline < /tmp/petclinic_job.xml
    sudo systemctl restart jenkins.service
    sudo systemctl status jenkins.service
	while ! httping -qc1 http://localhost:8081 ; do sleep 15; echo echo "===> WAIT UNTIL JENKIS STARTS"; done
	java -jar jenkins-cli.jar -s http://127.0.0.1:8081/ build 'Spring_Petclinic_Pipeline'
    
