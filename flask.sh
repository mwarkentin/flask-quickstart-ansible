#!/usr/bin/env bash -xe

SECURITY_GROUP="michaelw-flask-quickstart-sg"

aws ec2 create-security-group --group-name $SECURITY_GROUP --description "test security group for job application"
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 22 --cidr 0.0.0.0/0
INSTANCE_ID=`aws ec2 run-instances --image-id ami-4b630d2e --count 1 --instance-type t1.micro --key-name aws-wave-mwarkentin --security-groups $SECURITY_GROUP --query 'Instances[0].InstanceId' | tr -d '"'`
echo "Instance ID: $INSTANCE_ID"
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "$INSTANCE_ID is now running"
INSTANCE_IP=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output=text`
aws ec2 describe-instances --instance-ids $INSTANCE_ID > instance.json
echo "$INSTANCE_ID IP: $INSTANCE_IP"
