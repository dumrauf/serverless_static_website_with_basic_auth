#!/usr/bin/env bash

########################################################################################################################
# DIRECTORIES
########################################################################################################################
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_DIR="${BASE_DIR}/.."
ARTEFACTS_DIR="${BASE_DIR}/../.artefacts"


# Bootstrap required directories
mkdir -p "${ARTEFACTS_DIR}"




########################################################################################################################
# SERVERLESS STATIC WEBSITE WITH BASIC AUTH
########################################################################################################################
# Output Definitions
SERVERLESS_WEBSITE_BUCKET_NAME="serverless_website_bucket_name"
SERVERLESS_WEBSITE_DISTRIBUTION_ID="serverless_website_distribution_id"
