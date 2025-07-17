#!/bin/bash

. ./functions.sh
check_required_variables "DEPLOYMENT_NAME" "ENVIRONMENT" "LOC_CODE"
check_azure_cli_logged_in

resourceGroupAcaName="rg-aca-${ENVIRONMENT}-${DEPLOYMENT_NAME}-${LOC_CODE}"
containerAppsEnvName="ae-${ENVIRONMENT}-${DEPLOYMENT_NAME}-${LOC_CODE}"
managedIdentityAppName="mi-app-${ENVIRONMENT}-${DEPLOYMENT_NAME}-${LOC_CODE}"
acrName="cr${DEPLOYMENT_NAME}${LOC_CODE}"

managedIdentityId=$(az identity show --resource-group ${resourceGroupAcaName} --name ${managedIdentityAppName} --query id --output tsv | tr -d '[:space:]')

run_task demoapp1-nginx-reverse-proxy "./Dockerfile" "./nginx-reverse-proxy/"
taskRunId=$(get_last_successful_run_id $acrName "demoapp1-nginx-reverse-proxy" | tr -d '[:space:]')
echo "Task run ID: $taskRunId"

az containerapp create \
    --resource-group $resourceGroupAcaName \
    --environment $containerAppsEnvName \
    --name demoapp1-nginx-reverse-proxy \
    --registry-identity $managedIdentityId \
    --registry-server "${acrName}.azurecr.io" \
    --image "${acrName}.azurecr.io/demoapp1-nginx-reverse-proxy:${taskRunId}" \
    --ingress external \
    --target-port 80 \
    --env-vars API_URL=http://demoapp1-dotnet-api FRONTEND_URL=http://demoapp1-angular-frontend
