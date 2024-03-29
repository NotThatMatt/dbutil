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
wget https://github.com/datacharmer/test_db/archive/refs/heads/master.zip
unzip master.zip
cd test_db-master
touch options.ini
chmod 600 options.ini
cat << EOF > options.ini
[client]
host = $(aws secretsmanager get-secret-value --region us-east-1 --secret-id test/mysql  --query 'SecretString' --output text | jq .host | tr -d '"')
user = $(aws secretsmanager get-secret-value --region us-east-1 --secret-id test/mysql  --query 'SecretString' --output text | jq .username | tr -d '"')
password = $(aws secretsmanager get-secret-value --region us-east-1 --secret-id test/mysql  --query 'SecretString' --output text | jq .password | tr -d '"')
EOF
mysql --defaults-file=options.ini < employees.sql
rm -f options.ini
