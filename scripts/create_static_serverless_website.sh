#!/usr/bin/env bash

# Stop on all errors
set -e


if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <website-directory> <subdomain> <domain> <hosted-zone-id> <acm-certificate-arn> <profile>"
    echo "Example: $0" '"static-website-content/" "static-website" "mydomain.uk" "Z23ABC4XYZL05B" "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012" default'
    exit -1
fi


WEBSITE_DIRECTORY=$1
SUBDOMAIN=$2
DOMAIN=$3
SERVERLESS_WEBSITE_HOSTED_ZONE_ID=$4
ACM_CERTIFICATE_ARN=$5
PROFILE=$6


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


echo "---------- CREATING/UPDATING SERVERLESS CODE REPOSITORY ----------"
"${BASE_DIR}/bootstrap_serverless_repo.sh" "${PROFILE}"
echo "------------------------------------------------------------------"
echo
echo
echo


echo "--------------- CREATING SERVERLESS INFRASTRUCTURE ---------------"
"${BASE_DIR}/create_serverless_infrastructure.sh" "${SUBDOMAIN}" "${DOMAIN}" "${SERVERLESS_WEBSITE_HOSTED_ZONE_ID}" "${ACM_CERTIFICATE_ARN}" "${PROFILE}"
echo "------------------------------------------------------------------"
echo
echo
echo


echo "--------------------- UPLOADING TO S3 BUCKET ---------------------"
"${BASE_DIR}/upload_website_to_s3_bucket.sh" "${WEBSITE_DIRECTORY}" "${PROFILE}"
echo "------------------------------------------------------------------"
