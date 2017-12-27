#!/usr/bin/env bash


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <profile>"
    echo "Example: $0 default"
    exit -1
fi


source _configuration.sh
PROFILE=$1


{
    aws cloudformation create-stack --stack-name ${SERVERLESS_CODE_REPOSITORY_STACK_NAME} \
                                    --template-body file://"${BOOTSTRAP_SERVERLESS_CODE_REPOSITORY_TEMPLATE}" \
                                    --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" \
                                    --region ${REGION} \
                                    --profile ${PROFILE}
} || {
    aws cloudformation update-stack --stack-name ${SERVERLESS_CODE_REPOSITORY_STACK_NAME} \
                                    --template-body file://"${BOOTSTRAP_SERVERLESS_CODE_REPOSITORY_TEMPLATE}" \
                                    --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" \
                                    --region ${REGION} \
                                    --profile ${PROFILE}
}
