# Pipe 

This repository holds the code for my CI/CD Pipeline Application Project! 

Within this repo I have my Terraform code which provisions infrastructure on AWS. The specific infrastructure created includes: 
 - A VPC 
 - Public and Private Subnets in different Availability Zones (as is best practice) 
 - The infrastructure as well as the configurations to support the VPC and Subnets, such as Security Groups, Route Tables, an Internet Gateway as well as a NAT Gateway 
 - An Elastic Load Balancer 
 - An ECS Cluster, Service, and Tasks 
 - IAM Roles and Policies, including CloudWatch log permissions 
 - 2 S3 Buckets, one to store WebScraped data, another to store Terraform state
 
 The Repo also contains a Dockerfile to create a Docker Image. This is how I containerized a WebScraper application to upload to ECR and pulled to ECS. 
 That same docker file is also used with a CI/CD pipeline implemented using GitHub actions. Both the Python code and GitHub Actions configuration yaml file 
 are also within the repo 
 
 *Please note that the Terraform code will work with a simple copy-paste, but you'll have to input your own AWS Account ID within the ECR section of the code, 
 my apologies, I will update it with a variable substitution later to make it modular, if you get an error,m that is why
