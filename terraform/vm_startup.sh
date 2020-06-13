#! /bin/bash
apt-get update
mkdir /home/work
cd /home/work

# Install git and clone repository
apt-get install git -y
git clone https://github.com/CaioSGoncalves/DeltaTweets.git
cd DeltaTweets

# Install docker
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker 

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Copy bucket file to setup Twitter API credentials
gsutil cp gs://teste-caio/delta_tweets/scripts/set_credentials.sh /home/work/DeltaTweets/

# Run script to setup Twitter API credentials
chmod 777 set_credentials.sh
source ./set_credentials.sh

# docker-compose up
docker-compose up

