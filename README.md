`# Reservations Demo App

_All code written by Robert Benninger_

This is a small serverless python app created to demonstrate various cloud technologies, some of which I work with on a daily basis and some I've worked with in previous roles. The app consists of a small front-end script (`client-app/menu.py`) that allows you to interact with an AWS API Gateway via a text based menu. 

The app has 3 functions, each performed by a separate Lambda:

* View all reservations
* Add a reservation
* Delete a reservation

A reservation is a simple row of data in a DynamoDB table consisting of Name, Room #, Number of nights, and Reservation ID. The reservation app can be used by multiple customers. Each customer gets their own DynamoDB table. The customer name is passed to the Lambda functions via a request header in the front-end script which tells the lambda which table to access (front-end script -> nginx -> api gateway -> lambda -> dynamo). 

# Nginx

Nginx is deployed in an EKS pod that is sitting in front of the API Gateway. This pod was built with a Dockerfile and stored in an AWS Elastic Container Repository. The EKS cluster is configured with access to this repo and the latest pod gets deplooyed with `kubectl` by applying the configuration file in `eks-config/nginx-deployment.yaml`. Nginx passes the request along with the customer name in the header to the Lambda functions. Later this will be used to translate a friendly DNS name to a tenant ID for each customer's web requests. 

# Application Lambdas

Each application function unpacks the web request to get the customer name for routing to the correct table, and performs the basic operations of the menu option. For exmaple, when the customer wants to add a new reservation a json payload containeing the reservation details is passed with the request, and those details are written to that customer's DynamoDB table by the Lambda funtion. 

# EKS Management Lambdas

Since the EKS control plane is billed hourly and can't be paused or turned off, several lambdas have been created to completely tear down and rebuild the cluster according to my study schedule. An EKS cluster takes about 10 minutes to create or destroy so this saves me a lot of time and lets me get right to work in the small windows that I have evailable. This has many real-world applications as well, such as shutting down dev/test instances on a schedule to save money. 

* "Delete Cluster" lambda - this lambda uses the boto3 client to delete the nodegroup and then the cluster
* "Deploy Cluster" lambda - this lambda uses the terrasnek python library to interact with the Terraform Cloud API to execute a plan in the workspace I setup for this project. When the cluster is deleted its config stays in the Terraform state, so executing and applying a plan from this workspace simply re-creates the cluster with the correct settings. 
  
# Terraform code

Modularized Terraform code is used to deploy the reservations app (including API Gateway, DynamoDB, Lambda, EKS, and IAM resources) as well as the EKS Management lambdas.

# Lambda builds

An AWS Codebuid project with associated buildspec.yaml is used to buid all lambdas in the demo. The function name is passed to the Codebuild project via the FUNCTION_NAME environment variable. This stores the lambda zip artifact in an S3 bucket with the build ID appended to the file name. The build ID is passed back to Terraform to deploy the desired version of the lambda.
