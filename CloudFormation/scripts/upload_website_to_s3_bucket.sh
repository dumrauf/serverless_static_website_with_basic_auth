#!/usr/bin/env bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <website-directory> <profile>"
    echo 'Example: $0 "../static-website-content/" default'
    exit -1
fi


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${BASE_DIR}/_configuration.sh"
WEBSITE_DIRECTORY=$1
PROFILE=$2

SERVERLESS_WEBSITE_BUCKET=$(aws cloudformation describe-stacks --stack-name ${SERVERLESS_WEBSITE_WITH_BASIC_AUTH_STACK_NAME} \
                                                               --region ${REGION} \
                                                               --profile ${PROFILE} \
                                                               --query "Stacks[*].Outputs[?OutputKey == '${SERVERLESS_WEBSITE_BUCKET_NAME}'].OutputValue | [] | [0]" \
                                                               --output text)


echo "Using bucket ${SERVERLESS_WEBSITE_BUCKET} for upload..."

aws s3 sync ${WEBSITE_DIRECTORY} s3://${SERVERLESS_WEBSITE_BUCKET} --delete \
                                                                   --sse AES256 \
                                                                   --profile ${PROFILE} \
                                                                   --exclude "*.DS_Store"

echo "...done!"
