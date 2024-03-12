#!/bin/bash

# This script creates a service principal in Azure and sets the necessary environment variables.

# Install dependencies 
apt install jq

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if Azure CLI is installed
if ! command_exists az; then
  echo "Azure CLI is not installed. Please install it before running this script."
  exit 1
fi

# Log in to Azure CLI
az login

# Set the default subscription
echo "Setting default subscription..."
subscription_id=$(az account show --query id -o tsv)
az account set --subscription $subscription_id

# Create a service principal
echo "Creating service principal..."
sp_info=$(az ad sp create-for-rbac --role contributor --scopes "/subscriptions/$subscription_id")
client_id=$(echo $sp_info | jq -r '.appId')
client_secret=$(echo $sp_info | jq -r '.password')
tenant_id=$(az account show --query tenantId -o tsv)

# Set environment variables
echo "Setting environment variables..."
export ARM_CLIENT_ID="$client_id"
export ARM_CLIENT_SECRET="$client_secret"
export ARM_SUBSCRIPTION_ID="$subscription_id"
export ARM_TENANT_ID="$tenant_id"

echo "Service principal created successfully."