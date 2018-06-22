#!/usr/bin/env bash

# Stop on all errors
set -e


if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <website-directory> <aws-profile> <workspace-name>"
    echo "Example: $0" '"../static-website-content/" default static-website.example.com'
    exit -1
fi


WEBSITE_DIRECTORY=$1
PROFILE=$2
WORKSPACE=$3


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


echo "--------------- CREATING SERVERLESS INFRASTRUCTURE ---------------"
"${BASE_DIR}/create_serverless_infrastructure.sh" "${WORKSPACE}"
echo "------------------------------------------------------------------"
echo
echo
echo


echo "--------------------- UPLOADING TO S3 BUCKET ---------------------"
"${BASE_DIR}/upload_website_to_s3_bucket.sh" "${WEBSITE_DIRECTORY}" "${PROFILE}"
echo "------------------------------------------------------------------"
