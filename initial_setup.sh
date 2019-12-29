#! /bin/bash

set -ex

FILE=/home/viktor/docker_initialized
TEMP_DIR=/tmp/init_docker
JENKINS_HOME=/home/viktor/jenkins_home

if [ -e "$FILE" ]; then
    echo "Docker was already initialized... Leaving"
    exit 0
fi

systemctl enable docker.service
systemctl start docker.service

echo "Go to temp folder"
# Better do check for its presence and exit

if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

mkdir "$TEMP_DIR"
cd "$TEMP_DIR"

echo "Load config files from github"
wget https://raw.githubusercontent.com/vkolesnikov/dev_ops/master/Dockerfile-jenkins
wget https://raw.githubusercontent.com/vkolesnikov/dev_ops/master/plugins.txt
wget https://raw.githubusercontent.com/vkolesnikov/dev_ops/master/config.xml

echo "Clean docker leftovers"
docker container rm -f jenkins || true
docker rmi my_jenkins || true

echo "Build docker image for jenkins"
docker build -f Dockerfile-jenkins -t my_jenkins .

echo "Create and start jenkins container"
rm -rf "$JENKINS_HOME"
#if [ ! -d "$JENKINS_HOME" ]; then
echo "Create /home/viktor/jenkins_home"
mkdir "$JENKINS_HOME"
chmod a+w "$JENKINS_HOME"
#fi
docker create --name jenkins --restart=always --net=host -v "$JENKINS_HOME":/var/jenkins_home my_jenkins --httpPort=8081
docker start jenkins

echo "Sleep and wait for jenkins (better poll its api, but nvm)"
sleep 45

echo "Load jenkins-cli"
wget http://localhost:8081/jnlpJars/jenkins-cli.jar

echo "Create jenkins job"
java -jar jenkins-cli.jar -s http://localhost:8081 create-job my_new_job < $TEMP_DIR/config.xml

echo "Jenkins intallation is finished!"

echo "Install gerrit"

docker create --net=host --name gerrit --restart=always gerritcodereview/gerrit
docker start gerrit

echo "Gerrit is installed"

echo "Setting docker initialized file not to run this script in future"
touch "$FILE"
echo "1" > "$FILE"
echo "Done... Leaving"
