#!/usr/bin/env bash


if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <subdomain> <domain> <hosted-zone-id> <acm-certificate-arn> <profile>"
    echo "Example: $0" '"static-website" "mydomain.uk" "Z23ABC4XYZL05B" "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012" "default"'
    exit -1
fi


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${BASE_DIR}/_configuration.sh"


SUBDOMAIN=$1
DOMAIN=$2
SERVERLESS_WEBSITE_HOSTED_ZONE_ID=$3
ACM_CERTIFICATE_ARN=$4
PROFILE=$5


SERVERLESS_CODE_REPOSITORY_BUCKET=$(aws cloudformation describe-stacks --stack-name ${SERVERLESS_CODE_REPOSITORY_STACK_NAME} \
                                                                       --region ${REGION} \
                                                                       --profile ${PROFILE} \
                                                                       --query "Stacks[*].Outputs[?OutputKey == '${SERVERLESS_CODE_REPOSITORY_BUCKET_NAME}'].OutputValue | [] | [0]" \
                                                                       --output text)
echo "Using Serverless Code Repository Bucket ${SERVERLESS_CODE_REPOSITORY_BUCKET}..."



aws cloudformation package --template "${SERVERLESS_WEBSITE_WITH_BASIC_AUTH_TEMPLATE}" \
                           --s3-bucket ${SERVERLESS_CODE_REPOSITORY_BUCKET} \
                           --s3-prefix ${SERVERLESS_CODE_REPOSITORY_S3_PREFIX} \
                           --output-template-file "${PACKAGED_TEMPLATE_FILE}" \
                           --region ${REGION} \
                           --profile ${PROFILE}

aws cloudformation deploy --stack-name ${SERVERLESS_WEBSITE_WITH_BASIC_AUTH_STACK_NAME} \
                          --template "${PACKAGED_TEMPLATE_FILE}" \
                          --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" \
                          --region ${REGION} \
                          --profile ${PROFILE} \
                          --parameter-overrides ServerlessWebsiteSubdomainName="${SUBDOMAIN}" \
                                                ServerlessWebsiteDomainName="${DOMAIN}" \
                                                ServerlessWebsiteAcmCertificateArn="${ACM_CERTIFICATE_ARN}" \
                                                ServerlessWebsiteHostedZoneId="${SERVERLESS_WEBSITE_HOSTED_ZONE_ID}"


echo "...done!"
