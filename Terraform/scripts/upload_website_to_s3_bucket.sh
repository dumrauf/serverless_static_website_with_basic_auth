#!/usr/bin/env bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <website-directory> <profile>"
    echo "Example: $0 '../static-website-content/' default"
    exit -1
fi


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${BASE_DIR}/_configuration.sh"
WEBSITE_DIRECTORY=$1
PROFILE=$2


pushd ../ > /dev/null
SERVERLESS_WEBSITE_BUCKET=$(terraform output serverless_website_bucket_name)
popd > /dev/null


echo "Using bucket ${SERVERLESS_WEBSITE_BUCKET} for upload..."

aws s3 sync ${WEBSITE_DIRECTORY} s3://${SERVERLESS_WEBSITE_BUCKET} --delete \
                                                                   --sse AES256 \
                                                                   --profile ${PROFILE} \
                                                                   --exclude "*.DS_Store"

echo "...done!"
