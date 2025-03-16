#!/bin/bash

# Set color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get project ID
PROJECT_ID=$(gcloud config get-value project)
echo -e "${BLUE}🔍 Using project: ${YELLOW}${PROJECT_ID}${NC}"

# Get service name and region
SERVICE_NAME="ollama-backend"
REGION="asia-southeast1"
echo -e "${BLUE}🌏 Service region: ${YELLOW}${REGION}${NC}"

# Get service URL
echo -e "${BLUE}⏳ Retrieving Cloud Run service information...${NC}"
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format="value(status.url)")
SERVICE_HOST=$(echo $SERVICE_URL | sed 's/https:\/\///')

# Set environment variables
export OLLAMA_SERVICE_HOST=$SERVICE_HOST
export GOOGLE_AUTH_TOKEN=$(gcloud auth print-identity-token)

echo -e "${GREEN}✅ Service URL: ${YELLOW}${SERVICE_URL}${NC}"
echo -e "${GREEN}✅ Service Host: ${YELLOW}${SERVICE_HOST}${NC}"

# Switch to the parent directory of the script
cd "$(dirname "$0")/.."

echo -e "${GREEN}🚀 Starting Traefik proxy...${NC}"
echo -e "${YELLOW}📝 Traefik dashboard: ${NC}http://localhost:8087"
echo -e "${YELLOW}📝 Ollama API service: ${NC}http://localhost:11434"
echo -e "${YELLOW}❗ Press Ctrl+C to terminate${NC}"
echo ""

# Start Traefik
traefik --configfile="./config/traefik.yml"
