#!/bin/bash
########################################
#
# Using the cloudformation template creates
# an ec2 instance with java8 on ubuntu
#
#########################################

clear
IP_ADDRESS=$(wget -qO- http://checkip.amazonaws.com/)
echo " "
echo "Enter the IAM role"
read -r IAM_ROLE
echo " "
echo "Enter the ssh key pair name"
read -r KEY_PAIR
echo " "
echo "Enter the instance name"
read -r EC2_NAME
echo ""
read -e -p "Enter Template filepath: " TEMPLATE
echo ""

SSH_CIDR="$IP_ADDRESS/32"

STACK_NAME="$EC2_NAME-stack"
NEW_STACK_STATUS=" "

aws cloudformation create-stack --stack-name $STACK_NAME --template-body file:////$TEMPLATE --parameters ParameterKey=InstanceNameTag,ParameterValue=$EC2_NAME  ParameterKey=KeyPairName,ParameterValue=$KEY_PAIR ParameterKey=IamProfileName,ParameterValue=$IAM_ROLE ParameterKey=SSHLocation,ParameterValue=$SSH_CIDR

echo ""
echo "Creating stack for ec2 java8 ubuntu instance (security group ingress ip: $SSH_CIDR)"
echo " "

for i in {1..30}
do
	NEW_STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[*].[StackStatus]' --output text)
	echo "Stack Status: $NEW_STACK_STATUS"
	if [ $NEW_STACK_STATUS == "CREATE_COMPLETE" ]
		then echo " " 
		aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[*].[Outputs]' --output text 
		echo " "
		break
	elif [ $NEW_STACK_STATUS == "ROLLBACK_COMPLETE" ]
		then echo " "
		break
	fi
	sleep 10
done

echo " "
echo "access server with ssh (ssh -i {key_pair} -p 22 ubuntu@{instance_public_dns})"
echo " "
