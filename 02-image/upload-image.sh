#!/bin/bash

set -e

if [ -z "${AWS_ACCOUNT}" ]; then
    echo "AWS_ACCOUNT needs to be set"
    exit -1
fi

if [ -z "${AWS_REGION}" ]; then
    echo "AWS_REGION needs to be set"
    exit -1
fi

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com
docker build -t hello-world-image ..
docker tag hello-world-image:latest ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/hello-world-image:latest
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/hello-world-image:latest