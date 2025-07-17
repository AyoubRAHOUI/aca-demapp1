#!/bin/bash

# This script is used to deploy all three apps.

. ./functions.sh
check_required_variables "DEPLOYMENT_NAME" "ENVIRONMENT" "LOC_CODE" "APP_INSIGHTS_CONNECTION_STRING"

./dotnet-api/deploy-dotnet-api.sh
./angular-frontend/deploy-angular-frontend.sh
./nginx-reverse-proxy/deploy-nginx-reverse-proxy.sh