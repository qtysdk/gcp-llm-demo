# GCP LLM Demo Project Makefile

# Variable definitions
PROJECT_ID := $(shell gcloud config get-value project)
REGION := asia-southeast1
REPOSITORY := llm-models
SERVICE_NAME := ollama-backend
IMAGE_NAME := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPOSITORY)/ollama-backend:latest

# Color definitions
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help setup build deploy describe destroy clean

# Default target: Display help
help:
	@echo "$(GREEN)GCP LLM Demo Project Usage:$(NC)"
	@echo "  make setup     - Set up the project environment and enable required GCP APIs"
	@echo "  make build     - Build the container image"
	@echo "  make deploy    - Deploy the container to Cloud Run (requires GPU quota)"
	@echo "  make describe  - Show details of the deployed service"
	@echo "  make destroy   - Remove all resources"
	@echo "  make clean     - Remove local temporary files"
	@echo ""

	@echo "$(YELLOW)Project Information:$(NC)"
	@echo "  Project ID: $(PROJECT_ID)"
	@echo "  Region: $(REGION)"
	@echo "  Container Image: $(IMAGE_NAME)"

# Set up the project environment
setup:
	@echo "$(GREEN)Setting up the project environment...$(NC)"
	@python scripts/setup_project.py

# Build the container image
build:
	@echo "$(GREEN)Building the container image...$(NC)"
	@echo "$(YELLOW)Note: This process may take over 30 minutes$(NC)"
	@gcloud builds submit --config=cloudbuild.yaml

# Deploy to Cloud Run
deploy:
	@echo "$(GREEN)Deploying to Cloud Run...$(NC)"
	@chmod +x bin/deploy.sh
	@bin/deploy.sh

# Show deployed service details
describe:
	@echo "$(GREEN)Service Details:$(NC)"
	@gcloud run services describe $(SERVICE_NAME) --region $(REGION)

# Remove all resources
destroy:
	@echo "$(RED)Warning: This will remove all resources!$(NC)"
	@chmod +x bin/destroy.sh
	@bin/destroy.sh

# Remove local temporary files
clean:
	@echo "$(GREEN)Cleaning up local temporary files...$(NC)"
	@find . -name "__pycache__" -type d -exec rm -rf {} +
	@find . -name "*.pyc" -delete
	@find . -name ".DS_Store" -delete
	@echo "$(GREEN)Cleanup complete!$(NC)"
