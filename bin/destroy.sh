#!/bin/bash

# Enable strict mode: Exit on any error
set -e

# Function to print messages with colors
print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# Retrieve the current project ID
PROJECT_ID=$(gcloud config get-value project)
REGION="asia-southeast1"
REPOSITORY="llm-models"
SERVICE_NAME="ollama-backend"

print_info "Starting resource cleanup in project '$PROJECT_ID'..."

# Ask for confirmation
read -p "Are you sure you want to delete all resources? This action is irreversible (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Operation canceled."
    exit 0
fi

# Check and delete Cloud Run service
print_info "Checking Cloud Run service '$SERVICE_NAME'..."
if gcloud run services describe $SERVICE_NAME --region $REGION &> /dev/null; then
    print_info "Deleting Cloud Run service '$SERVICE_NAME'..."
    gcloud run services delete $SERVICE_NAME --region $REGION --quiet
    print_success "Cloud Run service '$SERVICE_NAME' deleted."
else
    print_warning "Cloud Run service '$SERVICE_NAME' does not exist. Skipping."
fi

# Check and delete Artifact Registry images
print_info "Checking Artifact Registry images..."
REPO_PATH="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/ollama-backend"

if gcloud artifacts repositories describe $REPOSITORY --location $REGION &> /dev/null; then
    # Check if images exist
    if gcloud artifacts docker images list $REPO_PATH --include-tags &> /dev/null; then
        print_info "Deleting Artifact Registry container images..."

        # List and delete all tags
        TAGS=$(gcloud artifacts docker tags list $REPO_PATH --format="value(tag)")
        for TAG in $TAGS; do
            print_info "Deleting image tag: $REPO_PATH:$TAG"
            gcloud artifacts docker tags delete $REPO_PATH:$TAG --quiet
        done
        
        print_success "All container image tags deleted."
    else
        print_warning "No images found in Artifact Registry. Skipping."
    fi

    # Finally, delete the repository
    print_info "Deleting Artifact Registry repository '$REPOSITORY'..."
    gcloud artifacts repositories delete $REPOSITORY --location $REGION --quiet
    print_success "Artifact Registry repository '$REPOSITORY' deleted."
else
    print_warning "Artifact Registry repository '$REPOSITORY' does not exist. Skipping."
fi

print_success "Resource cleanup completed!"
print_info "Note: This script does not disable enabled APIs, as they may be used by other projects."
print_info "To disable APIs, use the Google Cloud Console or gcloud CLI."
