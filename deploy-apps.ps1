# Azure Container Apps Demo

$RESOURCE_GROUP="rg-aca-demoapp1"
$LOCATION="westeurope"
$ACA_ENVIRONMENT="ae-aca-demoapp1"
$ACA_BACKEND_API="demoapp1-dotnet-api"
$ACA_FRONTEND_UI="demoapp1-angular-frontend"
$ACA_PROXY="demoapp1-nginx-reverse-proxy"
$ACR_NAME="acrdemoapp1"
$IDENTITY="mi-aca-demoapp1"

# Create a resource group
az group create `
         --name $RESOURCE_GROUP `
         --location $LOCATION

# Create an Azure Container Registry
az acr create `
       --resource-group $RESOURCE_GROUP `
       --name $ACR_NAME `
       --sku Basic `
       --admin-enabled false

# Build the container with ACR
az acr build --registry $ACR_NAME --image $ACA_BACKEND_API ./dotnet-api

# Create a Container Apps environment
az containerapp env create `
                --name $ACA_ENVIRONMENT `
                --resource-group $RESOURCE_GROUP `
                --location $LOCATION

# Create an identity for the container app
az identity create `
            --resource-group $RESOURCE_GROUP `
            --name $IDENTITY

# Get Identity Client ID
$IDENTITY_CLIENT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $IDENTITY --query clientId -o tsv)

$ACR_ID=$(az acr show `
        --resource-group $RESOURCE_GROUP `
        --name $ACR_NAME `
        --query id)

# Assign RBAC role ACRpull to the identity
az role assignment create `
        --role AcrPull `
        --assignee $IDENTITY_CLIENT_ID `
        --scope $ACR_ID

# Get identity's resource ID
$IDENTITY_RESOURCE_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $IDENTITY --query id -o tsv)

echo $IDENTITY_RESOURCE_ID

# Deploy your backend image to a container app
az containerapp create `
                --name $ACA_BACKEND_API `
                --resource-group $RESOURCE_GROUP `
                --environment $ACA_ENVIRONMENT `
                --image $ACR_NAME'.azurecr.io/'$ACA_BACKEND_API `
                --target-port 80 `
                --ingress 'internal' `
                --registry-server $ACR_NAME'.azurecr.io' `
                --user-assigned $IDENTITY_RESOURCE_ID `
                --registry-identity $IDENTITY_RESOURCE_ID

# Build the front end application
az acr build --registry $ACR_NAME --image $ACA_FRONTEND_UI .\angular-frontend

# Deploy front end application
az containerapp create `
                --name $ACA_FRONTEND_UI `
                --resource-group $RESOURCE_GROUP `
                --environment $ACA_ENVIRONMENT `
                --image $ACR_NAME'.azurecr.io/'$ACA_FRONTEND_UI  `
                --target-port 80 `
                --ingress 'internal' `
                --registry-server $ACR_NAME'.azurecr.io' `
                --user-assigned $IDENTITY_RESOURCE_ID `
                --registry-identity $IDENTITY_RESOURCE_ID

# GET THE FQDNs BEFORE DEPLOYING PROXY
$API_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $ACA_BACKEND_API --query properties.configuration.ingress.fqdn -o tsv)
$FRONTEND_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $ACA_FRONTEND_UI --query properties.configuration.ingress.fqdn -o tsv)

Write-Host "API Base URL: $API_BASE_URL"
Write-Host "Frontend Base URL: $FRONTEND_BASE_URL"

# Build the nginx proxy application
az acr build --registry $ACR_NAME --image $ACA_PROXY .\nginx-reverse-proxy

# Deploy proxy application with correct environment variables
az containerapp create `
                --name $ACA_PROXY `
                --resource-group $RESOURCE_GROUP `
                --environment $ACA_ENVIRONMENT `
                --image $ACR_NAME'.azurecr.io/'$ACA_PROXY  `
                --target-port 80 `
                --env-vars API_URL=https://$API_BASE_URL FRONTEND_BASE_URL=https://$FRONTEND_BASE_URL `
                --ingress 'external' `
                --registry-server $ACR_NAME'.azurecr.io' `
                --user-assigned $IDENTITY_RESOURCE_ID `
                --registry-identity $IDENTITY_RESOURCE_ID

# Clean up resources

# az group delete --name $RESOURCE_GROUP --yes --no-wait