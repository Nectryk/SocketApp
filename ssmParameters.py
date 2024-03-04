import boto3
import json
import getpass

client = boto3.client('ssm')

db_endpoint = input("Enter the database endpoint: ")
db_username = input("Enter the database username: ")
db_password = getpass.getpass("Enter the database password: ")
db_name = input("Enter the database name: ")

db_credentials = {
    "db-endpoint": db_endpoint,
    "username": db_username,
    "password": db_password,
    "db-name": db_name
}

value = json.dumps(db_credentials)

response = client.put_parameter(
    Name='/dev/DB_CREDENTIALS',
    Description='Database credentials',
    Value=value,
    Type='SecureString',
    Overwrite=True,
    Tier='Standard',
    DataType='text'
)

print("Parameter created:", response)

access_key_id = input("Enter your AWS Access Key ID: ")
secret_access_key = getpass.getpass("Enter your AWS Secret Access Key: ")
session_token = input("Enter your AWS Session Token: ")

aws_credentials = {
    "access_key_id": access_key_id,
    "secret_access_key": secret_access_key,
    "session_token": session_token
}

value = json.dumps(aws_credentials)

response = client.put_parameter(
    Name='/dev/AWS_CREDENTIALS',
    Description='AWS temporary credentials',
    Value=value,
    Type='SecureString',
    Overwrite=True,
    Tier='Standard',
    DataType='text'
)

print("Parameter created:", response)