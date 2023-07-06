# reservations-app

_All code written by Robert Benninger_

This is a small serverless python app created to demonstrate various cloud technologies. The app consists of a small front-end script (client-app/menu.py) that allows you to interact with an AWS API Gateway. The app has 4 functions, each performed by a separate Lambda:

* View all reservations
* Add a reservation
* Delete a reservation

A reservation is a simple row of data in a DynamoDB table consisting of Name, Room #, Number of nights, and Reservation ID.

The reservation app can be used by multiple customers. Each customer gets their own DynamoDB table. The customer name is passed to the Lambda functions via a request header. 

In front of the API Gateway is an EKS cluster running nginx pods. Nginx can be used for API key validation and advanced routing.

# cost savings lambdas

"Delete Cluster" and "Deploy Cluster" Lambdas are used to completely tear and re-deploy the EKS cluster on a schedule to save costs. The delete Lambda uses a python script to destroy the EKS nodegroup and cluster. The deploy Lambda is used to trigger a Terraform Cloud run which rebuids the cluster and nodegroup. This is done to prevent control plane charges from accruing outside the hours that this particular demo project is being developed on. 

# Terraform code

Modularized Terraform code is used to deploy API Gateway, DynamoDB, Lambda, EKS, and IAM resources.

# Lambda builds

An AWS Codebuid project with associated buildspec.yaml is used to buid all lambdas in the demo. The function name is passed to the Codebuild project via the FUNCTION_NAME environment variable. This stores the lambda zip artifact in an S3 bucket with the build ID appended to the file name. The buid ID is passed back to Terraform to deploy the desired version of the lambda.
