#!/bin/bash

echo "building $1..."
docker build -t $1 .

echo "tagging $1..."
docker tag $1 261220833951.dkr.ecr.us-east-1.amazonaws.com/demo:$1

echo "pushing $1..."
docker push 261220833951.dkr.ecr.us-east-1.amazonaws.com/demo:$1
