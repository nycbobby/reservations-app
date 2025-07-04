# Reservations Demo App 

_All code written by Robert Benninger_ 

This is a small serverless python app created to demonstrate various cloud technologies, some of which I work with on a daily basis and some I've worked with in previous roles. The app consists of a small front-end script (`client-app/menu.py`) that allows you to interact with an AWS API Gateway via a text based menu. 

The app has 3 functions, each performed by a separate Lambda:

* View all reservations
* Add a reservation
* Delete a reservation

_Example application menu screen when listing all current reservations:_

![image](https://github.com/nycbobby/reservations-app/assets/47117909/1fbc7259-7b14-4bdf-8413-354125deba0e)

A reservation is a simple row of data in a DynamoDB table consisting of Name, Room #, Number of nights, and Reservation ID. The reservation app can be used by multiple customers. Each customer gets their own DynamoDB table. The customer name is passed to the Lambda functions via a request header in the front-end script which tells the lambda which table to access. 

_front-end script -> nginx -> api gateway -> lambda -> dynamo_ 

# Terraform Code

Modularized Terraform code (stored in `/terraform`) is used to deploy the reservations app (including API Gateway, DynamoDB, Lambda, EKS, and IAM resources) as well as the EKS Management lambdas through a Terraform Cloud workspace.

# Application Lambdas

Each application function unpacks the web request to get the customer name for routing to the correct table and performs the basic operations associated with that menu option of the client script. For example, when the customer wants to add a new reservation a json payload containing the reservation details is passed with the request, and those details are written to that customer's DynamoDB table by the Lambda funtion. 

# Nginx

Nginx is deployed in an EKS pod (Elastic Kubernetes Services) that is sitting in front of the API Gateway. This pod was built with a Dockerfile and stored in an AWS Elastic Container Repository (ECR). The EKS cluster is configured with access to this repo and the latest pod gets deployed with `kubectl` by applying the configuration file in `eks-config/nginx-deployment.yaml`. A future improvement to this demo will use the nginx server to translate a friendly DNS name to a tenant ID for each customer's web requests, to simulate traditional real world scenarios where SaaS product customers use _customer_name.domain.com_ addresses to access a cloud service.

# EKS Management Lambdas (Elastic Kubernetes Service)

EKS is used to host nginx. Since the EKS control plane is billed hourly and can't be paused or turned off, several lambdas have been created to completely tear down and rebuild the cluster according to my study schedule. An EKS cluster takes about 10 minutes to create or destroy so this saves me a lot of time and reduces costs. This has many real-world applications as well, such as shutting down dev/test instances on a schedule to save money. These lambda are executed on a schedule via Cloudwatch Event Rules, which are deployed via Terraform.

* `Delete Cluster` lambda - this lambda uses the boto3 client to delete the nodegroup and then the cluster
* `Deploy Cluster` lambda - this lambda uses the terrasnek python library to interact with the Terraform Cloud API to execute a plan in the workspace I setup for this project. When the cluster is deleted its config stays in the Terraform state, so executing and applying a plan from this workspace simply re-creates the cluster with the correct settings. 

# Lambda Builds

An AWS Codebuid project with associated buildspec.yaml is used to buid all lambdas in the demo. The function name is passed to the Codebuild project via the FUNCTION_NAME environment variable. This stores the lambda zip artifact in an S3 bucket with the build ID appended to the file name. The build ID is passed back to Terraform to deploy the desired version of the lambda.

# 

![image](https://github.com/nycbobby/reservations-app/assets/47117909/7a4d8dc0-c189-4c9e-8e80-f5c289d2bdae)

