#!/usr/bin/env bash
set -o errexit
set -x


for y in aws jq; do
  if ! hash $y >/dev/null 2>&1; then
    printf "Can't find $y, exiting ...."
    exit 1
  fi
done

usage() {
echo "Script takes five parameters: \
$0 <region> <user> <bucket> <project> <ticket>"
}

if [[ "$#" -lt 3 ]]; then
  usage && exit 1
fi

# eventually all these will be replaced with lookups
export REGION=$1
export USER=$2
export BUCKET=$3
export PROJECT=$4
export TICKET=$5


aws --region ${REGION} \
  cloudformation create-stack \
  --capabilities CAPABILITY_IAM \
  --capabilities CAPABILITY_NAMED_IAM \
  --stack-name ${REGION}-${PROJECT}-${TICKET} \
  --timeout-in-minutes 3 \
  --template-body file:////$(pwd)/cf-templates/iamUser.json \
  --parameters ParameterKey=UserName,ParameterValue=${USER}\
,UsePreviousValue=False \
ParameterKey=BucketName,ParameterValue=${BUCKET}\
,UsePreviousValue=False \
ParameterKey=ProjectName,ParameterValue=${PROJECT}\
,UsePreviousValue=False \
ParameterKey=TicketNumber,ParameterValue=${TICKET} \
 | tee  ${TICKET}.txt

export STACK_NAME=$(cat ${TICKET}.txt | jq -r .StackId)

# going to be lazy here and just sleep rather than writting a check/wait/check func


docfnquery() {
aws --region ${REGION} \
 cloudformation describe-stacks \
 --stack-name ${STACK_NAME} | tee /tmp/${TICKET}.txt
}

inspectquery() {
jq -e -M '.Stacks[].Outputs[].OutputValue' /tmp/${TICKET}.txt
}

retcode=5; while [ ${retcode} -ne 0 ]; do
    sleep 15 && docfnquery && inspectquery && retcode=$?
    done
