#!/usr/bin/env bash

########################################################################################################################
# BASIC SETTINGS
########################################################################################################################
# Note that as of end of 2017, edge lambda functions can only be located in us-east-1;
# see also <http://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html#lambda-edge-create-function>
REGION="us-east-1"



########################################################################################################################
# DIRECTORIES
########################################################################################################################
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_DIR="${BASE_DIR}/.."
ARTEFACTS_DIR="${BASE_DIR}/../.artefacts"


# Bootstrap required directories
mkdir -p "${ARTEFACTS_DIR}"




########################################################################################################################
# SERVERLESS CODE REPOSITORY
########################################################################################################################
BOOTSTRAP_SERVERLESS_CODE_REPOSITORY_TEMPLATE="${TEMPLATE_DIR}/bootstrap_serverless_code_repository.yaml"
SERVERLESS_CODE_REPOSITORY_STACK_NAME="us-east-1-serverless-code-repository"
SERVERLESS_CODE_REPOSITORY_BUCKET_NAME="ServerlessCodeRepositoryBucketName"
SERVERLESS_CODE_REPOSITORY_S3_PREFIX="serverless-website-with-basic-auth"




########################################################################################################################
# SERVERLESS STATIC WEBSITE WITH BASIC AUTH
########################################################################################################################
_STACK_NAME_FILE="${ARTEFACTS_DIR}/.stack-name"
_STACK_BASE_NAME="us-east-1-serverless-website-with-basic-auth"


# Create/Retrieve Stack Name
if [ -f "${_STACK_NAME_FILE}" ]
then
    SERVERLESS_WEBSITE_WITH_BASIC_AUTH_STACK_NAME=$(cat "${_STACK_NAME_FILE}")
    echo "Using stack name ${SERVERLESS_WEBSITE_WITH_BASIC_AUTH_STACK_NAME} stored in file ${_STACK_NAME_FILE}..."
else
    random_string=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    SERVERLESS_WEBSITE_WITH_BASIC_AUTH_STACK_NAME="${_STACK_BASE_NAME}-${random_string}"
    echo "Created new stack name ${SERVERLESS_WEBSITE_WITH_BASIC_AUTH_STACK_NAME}!"
    echo "${SERVERLESS_WEBSITE_WITH_BASIC_AUTH_STACK_NAME}" > "${_STACK_NAME_FILE}"
    echo "Stored new stack name ${SERVERLESS_WEBSITE_WITH_BASIC_AUTH_STACK_NAME} in file ${_STACK_NAME_FILE} for future use..."
fi


# Template Definitions
SERVERLESS_WEBSITE_WITH_BASIC_AUTH_TEMPLATE="${TEMPLATE_DIR}/serverless_static_website_with_basic_auth.yaml"
PACKAGED_TEMPLATE_FILE="${ARTEFACTS_DIR}/packaged-template.yaml"


# Output Definitions
SERVERLESS_WEBSITE_BUCKET_NAME="ServerlessWebsiteBucketName"
SERVERLESS_WEBSITE_DISTRIBUTION_ID="ServerlessWebsiteDistributionId"
