#AWS Infrastructure Deployment for Client-Server Application

[Architecture](https://github.com/Nectryk/SocketApp/blob/main/ArchitectureSocketApp.drawio.png)

This project contains an application which is a client who communicates via socket to a server in NodeJS, the server harvest the client IP and PORT and insert the data to a MySQL database. Inspired by IoT, this project aims to facilitate seamless data handling. In addition, to check the data from the database I created a web application on apache web server, PHP retrieves data from Elasticache Memcached if it's there, if not, it query the database and upload the data to the cache in a lazy loading cache strategy. an ALB (Application Load Balancer) and ASG (Auto Scaling Group) allows my web application to be fully scalable and highly available. Thanks to Python and Boto3 I can upload my database credentials and AWS credentials to the SSM Parameter Store so my applications can use them in a secure way. Due to my AWS Academy account restriction I had to introduce my credentials to SSM Parameter Store but in a real environment you should use an appropriate Instance Role so the application communicates with instance metadata to interact with other AWS resources. To keep pinging from the client I made use of a cron job in the User data. The database credentials are stored in the secrets.tfvars and in plain text in the PHP instance User data, Although the secrets.tfvars has been exemplarily pushed to Git, in actual deployments, it should be excluded via .gitignore. In a production environment you must avoid including credentials in plain text, database hardening should be done in a different way, Nonetheless, this approach was adopted for testing purposes.

##Prerequisites

Before running the deployment scripts, ensure that you have the following prerequisites:

- AWS CLI installed and configured with appropriate permissions.
- Terraform installed on your local machine.
- Python 3 installed on your local machine.
- Git installed for version control.

##Application deployment

1. Clone the repository to your local machine

```bash
git clone https://github.com/Nectryk/SocketApp.git && cd SocketApp
```

2. Login to your AWS account with AWS CLI.

```bash
aws configure
```

3. Execute the Terraform file for the VPC.

```bash
cd terraform/vpc && terraform init && terraform plan -out "vpc_plan" && terraform apply "vpc_plan"
```

4. Execute the RDS Terraform template for database setup. Username is admin and password secret09.

```bash
cd ../rds && terraform init && terraform plan -out "rds_plan" && terraform apply "rds_plan"
```
5. Obtain temporary credentials.

> Due to AWS Academy account restrictions, temporary credentials are obtained differently. 
> For your account, use the AWS CLI to acquire [temporary credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html).

6. Execute the Python script for setting up SSM Parameters. Database name is 

```bash
cd ../.. && python3 ssmParameters.py 
```

7. Deploy the web application with ALB, ASG, and Elasticache.

```bash
cd ../instance-php  && terraform init && terraform plan -out "web_app_plan" && terraform apply "web_app_plan"
```

8. Run the Terraform template for the NodeJS client and server.

```bash
cd terraform/instances-node && terraform init && terraform plan -out "node_plan" && terraform apply "node_plan"
```

9. Access the ALB endpoint in your browser to check the project.