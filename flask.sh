#!/usr/bin/env bash -xe

# Create security group
SECURITY_GROUP="michaelw-flask-quickstart-sg"
aws ec2 create-security-group --group-name $SECURITY_GROUP --description "test security group for job application"
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 80 --cidr 0.0.0.0/0

# Start EC2 instance
INSTANCE_ID=`aws ec2 run-instances --image-id ami-4b630d2e --count 1 --instance-type t1.micro --key-name aws-wave-mwarkentin --security-groups $SECURITY_GROUP --query 'Instances[0].InstanceId' | tr -d '"'`
echo "Instance ID: $INSTANCE_ID"

# Wait for instance to start
aws ec2 wait system-status-ok --instance-ids $INSTANCE_ID
echo "$INSTANCE_ID is now running and status checks passing"

# Output instance details to json
aws ec2 describe-instances --instance-ids $INSTANCE_ID > instance.json

# Get instance IP
INSTANCE_IP=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output=text`
echo "$INSTANCE_ID IP: $INSTANCE_IP"

# Generate ansible inventory
echo -e "[webservers]\n$INSTANCE_IP" > inventory

# Provision with ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbook.yml -i inventory

echo "The flask application is now running at http://$INSTANCE_IP or http://$INSTANCE_IP/hello"

# Clean up
read -p "Press any key to clean up AWS resources:" -n 1 -s
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
echo "$INSTANCE_ID is now terminated"
aws ec2 delete-security-group --group-name $SECURITY_GROUP
