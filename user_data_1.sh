#!/bin/bash
yum update -y
yum install -y docker
service docker start
docker run --name myadmin -d -e PMA_ARBITRARY=1 -p 80:80 phpmyadmin
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
host = $(aws secretsmanager get-secret-value --secret-id test/mysql  --query 'SecretString' --output text | jq .host | tr -d '"')
user = $(aws secretsmanager get-secret-value --secret-id test/mysql  --query 'SecretString' --output text | jq .username | tr -d '"')
password = $(aws secretsmanager get-secret-value --secret-id test/mysql  --query 'SecretString' --output text | jq .password | tr -d '"')
EOF
mysql --defaults-file=options.ini < employees.sql
rm -f options.ini