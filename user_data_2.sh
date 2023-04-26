#!/bin/bash
yum update -y
yum install -y docker
service docker start
docker run --name adminer1 -d -p 80:8080 adminer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
yum install -y jq
yum install -y mysql
mkdir db-data
cd db-data
wget https://raw.githubusercontent.com/aws-samples/amazon-aurora-mysql-sample-hr-schema/master/hr-schema.sql
touch options.ini
chmod 600 options.ini
cat << EOF > options.ini
[client]
host = $(aws secretsmanager get-secret-value --region us-east-1 --secret-id demo/mysql  --query 'SecretString' --output text | jq .host | tr -d '"')
user = $(aws secretsmanager get-secret-value --region us-east-1 --secret-id demo/mysql  --query 'SecretString' --output text | jq .username | tr -d '"')
password = $(aws secretsmanager get-secret-value --region us-east-1 --secret-id demo/mysql  --query 'SecretString' --output text | jq .password | tr -d '"')
EOF
mysql --defaults-file=options.ini < hr-schema.sql
rm -f options.ini
