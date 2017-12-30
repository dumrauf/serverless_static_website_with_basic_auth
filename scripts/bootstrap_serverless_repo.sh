#!/usr/bin/env bash


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <profile>"
    echo "Example: $0 default"
    exit -1
fi


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${BASE_DIR}/_configuration.sh"
PROFILE=$1


# Makeshift TRY/CATCH block
{
    STDERR=$(aws cloudformation create-stack --stack-name ${SERVERLESS_CODE_REPOSITORY_STACK_NAME} \
                                             --template-body file://"${BOOTSTRAP_SERVERLESS_CODE_REPOSITORY_TEMPLATE}" \
                                             --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" \
                                             --region ${REGION} \
                                             --profile ${PROFILE} 2>&1)

    # Inspired by <https://gist.github.com/jghaines/6b25a48c8531c236b0ec4831f4465ce4>
    ERROR_CODE=$?
    if [[ "${ERROR_CODE}" -eq "255" && "${STDERR}" =~ "AlreadyExistsException" ]]
    then
        false
    else
        true
    fi

} || {
    STDERR=$(aws cloudformation update-stack --stack-name ${SERVERLESS_CODE_REPOSITORY_STACK_NAME} \
                                             --template-body file://"${BOOTSTRAP_SERVERLESS_CODE_REPOSITORY_TEMPLATE}" \
                                             --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" \
                                             --region ${REGION} \
                                             --profile ${PROFILE} 2>&1)
    # Inspired by <https://gist.github.com/jghaines/6b25a48c8531c236b0ec4831f4465ce4>
    ERROR_CODE=$?
    if [[ "${ERROR_CODE}" -eq "255" && "${STDERR}" =~ "No updates are to be performed" ]]
    then
        exit 0
    else
        exit ${ERROR_CODE}
    fi
}
