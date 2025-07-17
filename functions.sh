#!/bin/bash

check_required_variables() {
    local variables=("$@")
    MISSING_VARIABLES=()

    # Check if the variables are set and not empty
    for var_name in "${variables[@]}"; do
        # Use indirect reference to get the value of the variable
        local value=${!var_name}
        if [ -z "$value" ]; then
            MISSING_VARIABLES+=("$var_name")
        fi
    done

    # If any variables are missing, print an error and exit
    if [ ${#MISSING_VARIABLES[@]} -ne 0 ]; then
        echo "The following environment variables are not set or empty:"
        for miss in "${MISSING_VARIABLES[@]}"; do
            echo "- $miss"
        done
        echo ""
        echo "Please ensure you've sourced the 'configure-deployment-environment.sh' script using the dot sourcing operator ('.'). Example:"
        echo ". ./configure-deployment-environment.sh"
        echo "Dot sourcing loads and executes the script in the current shell, making the exported variables available within this shell."
        echo ""
        echo "For a GitHub Workflow: Ensure you have set the required Environment Variables in the workflow's settings."
        exit 1
    fi
}


function run_task() {
    local imageName=$1
    local filePath=$2
    local context=$3
    local acrName="cr${DEPLOYMENT_NAME}${LOC_CODE}"
    local original_dir=$(pwd)

    cd $context

    echo "Running build-${imageName} task"
    az acr task run \
        --registry $acrName \
        --name "build-${imageName}" \
        --context . \
        --file $filePath

    cd $original_dir
}

function get_last_successful_run_id() {
    local acrName=$1
    local imageName=$2

    az acr task list-runs \
        --registry $acrName \
        --name "build-${imageName}" \
        --run-status Succeeded \
        --top 1 \
        --query '[0].runId' \
        --output tsv
}

function create_task() {
    local imageName=$1
    local filePath=$2
    local acrName="cr${DEPLOYMENT_NAME}${LOC_CODE}"

    echo "Creating build-${imageName} task"
    
    # Create an ACR task with no trigger enabled. The task will use a system-assigned identity.
    az acr task create \
        --registry $acrName \
        --name "build-${imageName}" \
        --auth-mode None \
        --context /dev/null \
        --file $filePath \
        --commit-trigger-enabled false \
        --base-image-trigger-enabled false \
        --pull-request-trigger-enabled false \
        --assign-identity

    # Get the principal ID for the system-assigned identity.
    systemAssignedIdentityPrincipalId=$(az acr task show --registry $acrName --name build-${imageName} --query identity.principalId --output tsv | tr -d '[:space:]')
    echo "systemAssignedIdentityPrincipalId: ${systemAssignedIdentityPrincipalId}"

    # Get the ID of the Azure Container Registry.
    acrId=$(az acr show --name ${acrName} --query id --output tsv | tr -d '[:space:]')
    echo "acrId: ${acrId}"

    # Assign the 'acrpush' role to the system-assigned identity. This allows the task to push images to the ACR.
    echo "Creating role assignment"
    az role assignment create \
    --assignee-object-id $systemAssignedIdentityPrincipalId \
    --assignee-principal-type ServicePrincipal \
    --scope $acrId \
    --role acrpush

    # Add registry credentials to the ACR task, using the system-assigned identity.
    echo "Adding task credential for build-${imageName} task"
    az acr task credential add \
        --name "build-${imageName}" \
        --registry $acrName \
        --login-server "${acrName}.azurecr.io" \
        --use-identity [system]
}

check_azure_cli_logged_in() {
    # Check if az CLI is installed
    if ! command -v az &> /dev/null; then
        echo "Error: Azure CLI (az) is not installed."
        exit 1
    fi

    # Attempt to list the resource groups to verify the authentication
    if ! az group list &> /dev/null; then
        echo "Error: Unable to list Azure resource groups. Ensure you're properly authenticated with 'az login'."
        exit 1
    fi

    echo "Azure CLI authentication verified successfully."
}
