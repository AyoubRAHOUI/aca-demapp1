#!/bin/bash

. ./functions.sh
check_required_variables "DEPLOYMENT_NAME" "ENVIRONMENT" "LOC_CODE" "APP_INSIGHTS_CONNECTION_STRING"
check_azure_cli_logged_in

resourceGroupAcaName="rg-aca-${ENVIRONMENT}-${DEPLOYMENT_NAME}-${LOC_CODE}"
containerAppsEnvName="ae-${ENVIRONMENT}-${DEPLOYMENT_NAME}-${LOC_CODE}"
managedIdentityAppName="mi-app-${ENVIRONMENT}-${DEPLOYMENT_NAME}-${LOC_CODE}"
acrName="cr${DEPLOYMENT_NAME}${LOC_CODE}"

managedIdentityId=$(az identity show --resource-group ${resourceGroupAcaName} --name ${managedIdentityAppName} --query id --output tsv | tr -d '[:space:]')

run_task "demoapp1-dotnet-api" "./Dockerfile" "./dotnet-api/"
taskRunId=$(get_last_successful_run_id $acrName "demoapp1-dotnet-api" | tr -d '[:space:]')
echo "Task run ID: $taskRunId"

az containerapp create \
    --resource-group $resourceGroupAcaName \
    --environment $containerAppsEnvName \
    --name demoapp1-dotnet-api \
    --registry-identity $managedIdentityId \
    --registry-server "${acrName}.azurecr.io" \
    --image "${acrName}.azurecr.io/demoapp1-dotnet-api:${taskRunId}" \
    --ingress internal \
    --target-port 80 \
    --secrets ai-connection-string=$APP_INSIGHTS_CONNECTION_STRING \
    --env-vars APPLICATIONINSIGHTS_CONNECTION_STRING=secretref:ai-connection-string
