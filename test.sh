#!/bin/bash

# -u オプションは未定義変数を使うとError
set -u

function try_send_message() {
  aws --profile $1 sqs send-message \
    --queue-url $2 \
    --message-body "すまん"
}

function show_q_size() {
  aws --profile $1 sqs get-queue-attributes \
    --queue-url $2 \
    --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesDelayed
}

function push_image() {
  aws --profile $1 ecr get-login --no-include-email | sh
  AWS_ECR_REPO_NAME=suman-ecr
  docker tag busybox:latest $2/${AWS_ECR_REPO_NAME}:latest
  docker push $2/${AWS_ECR_REPO_NAME}:latest
}

#echo "========================[SQS]"
#url=`aws sqs --profile suman get-queue-url --queue-name "suman-q" | jq -r --unbuffered ".QueueUrl"`
#try_send_message suman ${url}
#try_send_message gomen ${url}
#show_q_size suman ${url}
#show_q_size default ${url}
#aws --profile default sqs purge-queue --queue-url ${url}

echo "========================[ECR]"
if [ -z "${AWS_ECR_REGISTRY:+$AWS_ECR_REGISTRY}" ]; then
  AWS_ACCOUNT_ID=`aws --profile suman sts get-caller-identity | jq -r '.Account'`
  AWS_DEFAULT_REGION=ap-northeast-1
  AWS_ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
fi
echo "=============from suman]"
push_image suman ${AWS_ECR_REGISTRY}
echo "=============from gomen]"
push_image gomen ${AWS_ECR_REGISTRY}
