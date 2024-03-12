#!/bin/bash

# This script creates a service principal and updates the .env file with the necessary environment variables.

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

# Create or update .env file
env_file=".env"
echo "Creating $env_file..."
echo "# Azure" >> $env_file
echo "ARM_CLIENT_ID=\"$client_id\"" >> $env_file
echo "ARM_CLIENT_SECRET=\"$client_secret\"" >> $env_file
echo "ARM_SUBSCRIPTION_ID=\"$subscription_id\"" >> $env_file
echo "ARM_TENANT_ID=\"$tenant_id\"" >> $env_file

echo "Service principal created and environment variables updated in $env_file."
