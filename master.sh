#!/bin/bash

# Update system packages
sudo apt update
sudo apt upgrade -y

# Install OpenJDK 17
sudo apt install openjdk-17-jdk -y

# Install Apache Maven 3.9.7
sudo wget https://apache.osuosl.org/maven/maven-3/3.9.7/binaries/apache-maven-3.9.7-bin.tar.gz -P /tmp
sudo tar xf /tmp/apache-maven-3.9.7-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.7 /opt/maven
sudo ln -s /opt/maven/bin/mvn /usr/bin/mvn

# Install Git
sudo apt install git -y

# Install Docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Clean up temporary files
sudo rm -f /tmp/apache-maven-3.9.7-bin.tar.gz

# Install dos2unix
sudo apt update
sudo apt install dos2unix
dos2unix slave.sh  


echo "Setup complete!"
