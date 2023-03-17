#!/bin/bash -e

REGION=$1
URL=$2
APP=$3
IMAGE_TAG=$4
# Firstly check if docker is installed 
if ! command -v docker &> /dev/null
then
  echo "Install docker please"
fi

if ! command -v aws &> /dev/null
then
  echo "Install aws cli"
fi

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${URL}
docker build -t ${APP} ../
docker tag ${IMAGE_TAG} ${URL}/${IMAGE_TAG}
docker push ${URL}/${IMAGE_TAG}
sleep 2
docker image -qa|xargs docker rmi
docker builder prune