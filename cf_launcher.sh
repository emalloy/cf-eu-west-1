#!/usr/bin/env bash
set -o errexit
set -x

if ! hash aws >/dev/null 2>&1; then
  printf "Can't find awscli, exiting ...."
  exit 1
fi

usage() {
echo "Script takes seven parameters: \
$0 <db_type> <stackName> <keyPairName> <vpcId> <subnetId> <amiId> <securityGroupId>"
}

if [[ "$#" -lt 6 ]]; then
  usage && exit 1
fi

if [[ $1 == "cassandra" ]]; then
    DB_TYPE="cassandra"
    elif [[ $1 = "mongod" ]]; then
    DB_TYPE="mongod";
    elif [[ $1 = "nfs" ]]; then
    DB_TYPE="nfs";
else
    printf "db_type must be cassandra or mongod or nfs\n"
    exit 1
fi

# eventually all these will be replaced with lookups
STACK_NAME=$2
KEY_NAME=$3
VPC_ID=$4
SUBNET_ID=$5
AMI_ID=$6
SECURITY_GROUP_ID=$7
REGION=$8
INSTANCE_TYPE="m4.xlarge"

aws cloudformation create-stack \
  --stack-name ${STACK_NAME} \
  --on-failure DO_NOTHING \
  --template-body file:////$(pwd)/${DB_TYPE}.template \
  --parameters ParameterKey=KeyName,ParameterValue=${KEY_NAME}\
,UsePreviousValue=False \
ParameterKey=VpcId,ParameterValue=${VPC_ID}\
,UsePreviousValue=False \
ParameterKey=SubnetId,ParameterValue=${SUBNET_ID}\
,UsePreviousValue=False \
ParameterKey=AmiId,ParameterValue=${AMI_ID}\
,UsePreviousValue=False \
ParameterKey=SecurityGroupId,ParameterValue=${SECURITY_GROUP_ID}\
,UsePreviousValue=False \
ParameterKey=InstanceType,ParameterValue=${INSTANCE_TYPE}\
,UsePreviousValue=False \
ParameterKey=Region,ParameterValue=${REGION}\
,UsePreviousValue=False