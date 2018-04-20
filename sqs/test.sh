#!/bin/bash

set -o nounset -o errexit -o pipefail

QUEUE="ip-ranges-changes"
SQS="aws --profile=ip-ranges-changes sqs"
QURL="https://queue.amazonaws.com/788222722721/$QUEUE"

# $SQS send-message --queue-url $QURL --message-body "$(cat sqs/test.json)" > /dev/null


while sleep 1; do
  MSG=$($SQS receive-message --queue-url $QURL --wait-time-seconds 20)

  if [ ! -z "$MSG" ]; then
    echo "Received $MSG" | ts
    ID=$(echo $MSG | jq -r ".Messages[0].ReceiptHandle")
    BODY=$(echo $MSG | jq -r ".Messages[0].Body")
    MD5=$(echo $BODY | jq -r ".md5")
    TOKEN=$(echo $BODY | jq -r ".syncToken")
    URL=$(echo $BODY | jq -r .url)

    wget -q https://ip-ranges.amazonaws.com/ip-ranges.json -O ip-ranges.json
    JSON_MD5=$(md5sum ip-ranges.json | awk '{print $1}')

    if [[ $(git status -s ip-ranges.json) ]]; then
      git add ip-ranges.json
      git commit -m "updating ip-ranges.json"
      git push

     $SQS delete-message --queue-url $QURL --receipt-handle $ID
    else
      echo "no changes" | ts
    fi
  fi
done

