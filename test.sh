#!/bin/bash

function try_send_message() {
  aws --profile suman sqs send-message \
    --queue-url $1 \
    --message-body "すまん"
}

function show_q_size_from() {
  aws --profile $1 sqs get-queue-attributes \
    --queue-url $2 \
    --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesDelayed
}

url=`aws sqs --profile suman get-queue-url --queue-name "suman-q" | jq -r --unbuffered ".QueueUrl"`
try_send_message ${url}
show_q_size_from suman ${url}
show_q_size_from default ${url}

#aws --profile default sqs purge-queue --queue-url ${url}
