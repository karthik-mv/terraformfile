#! /bin/bash
# sudo yum install java-1.8.0-openjdk-devel -y
sudo yum install git -y
# sudo yum install maven -y
sudo yum install docker -y
sudo systemctl start docker

if [ -d "terraformfile" ]
then
  echo "repo is cloned and exists"
  cd /home/ec2-user/terraformfile
  git pull origin cicd-tf
else
  git clone https://github.com/karthik-mv/terraformfile.git
fi
cd /home/ec2-user/terraformfile
git checkout cicd-tf
sudo docker build -t $1:$2 /home/ec2-user/terraformfile
