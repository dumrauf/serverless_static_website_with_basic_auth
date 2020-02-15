#!/usr/bin/env bash


if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <workspace-name>"
    echo "Example: $0 static-website.example.com"
    exit -1
fi


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${BASE_DIR}/_configuration.sh"


WORKSPACE=$1


pushd ../  > /dev/null

# Select/Create Terraform Workspace
terraform workspace select "${WORKSPACE}"
IS_WORKSPACE_PRESENT=$?
if [ "${IS_WORKSPACE_PRESENT}" -ne "0" ]
then
    terraform workspace new "${WORKSPACE}"
fi

# Terraform Commands
terraform init
terraform apply -var-file=settings/"${WORKSPACE}".tfvars

popd > /dev/null
