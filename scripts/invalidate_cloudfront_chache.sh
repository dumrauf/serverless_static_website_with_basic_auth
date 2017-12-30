#!/usr/bin/env bash


if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <profile> <paths>"
    echo "Example: $0 default '/*' "
    echo "        (note the single quotes to avoid parameter expansion above!)"
    echo "Example: $0 default /index.html /static/js/map.js"
    exit -1
fi


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${BASE_DIR}/_configuration.sh"


PROFILE=$1
INVALIDATION_PATHS="${@:2}"


SERVERLESS_WEBSITE_DISTRIBUTION_ID=$(aws cloudformation describe-stacks --stack-name ${SERVERLESS_WEBSITE_WITH_BASIC_AUTH_STACK_NAME} \
                                                                        --region ${REGION} \
                                                                        --profile ${PROFILE} \
                                                                        --query "Stacks[*].Outputs[?OutputKey == '${SERVERLESS_WEBSITE_DISTRIBUTION_ID}'].OutputValue | [] | [0]" \
                                                                        --output text)


if [ "${INVALIDATION_PATHS}" == "'/*'" ]
then
    echo "Invalidating special path /* in CloudFront distribution ID ${SERVERLESS_WEBSITE_DISTRIBUTION_ID}..."
    aws cloudfront create-invalidation --distribution-id ${SERVERLESS_WEBSITE_DISTRIBUTION_ID} \
                                       --paths "/*"
else
    echo "Invalidating paths ${INVALIDATION_PATHS} in CloudFront distribution ID ${SERVERLESS_WEBSITE_DISTRIBUTION_ID}..."
    aws cloudfront create-invalidation --distribution-id ${SERVERLESS_WEBSITE_DISTRIBUTION_ID} \
                                       --paths ${INVALIDATION_PATHS}
fi

echo "...done!"
