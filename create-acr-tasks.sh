#!/bin/bash

# This script is used to create tasks in the Azure Container Registry (ACR).
# These tasks can be used to build and push images to the ACR from within the ACR.

. ./functions.sh
check_required_variables "DEPLOYMENT_NAME" "LOC_CODE"
check_azure_cli_logged_in

create_task "demoapp1-dotnet-api" "acrTasks/build-dotnet-api.yaml"
create_task "demoapp1-angular-frontend" "acrTasks/build-angular-frontend.yaml"
create_task "demoapp1-nginx-reverse-proxy" "acrTasks/build-nginx-reverse-proxy.yaml"
