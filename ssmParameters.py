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