#!/bin/bash

# Exit on any error
set -e

# Get the Google Cloud project ID
PROJECT_ID=$(gcloud config get-value project)
echo "Deploying to project: $PROJECT_ID"

# Deploy to Cloud Run with CPU only
gcloud run deploy ollama-backend \
  --image asia-southeast1-docker.pkg.dev/$PROJECT_ID/llm-models/ollama-backend:latest \
  --concurrency 1 \
  --cpu 4 \
  --set-env-vars OLLAMA_NUM_PARALLEL=8 \
  --max-instances 1 \
  --memory 16Gi \
  --no-allow-unauthenticated \
  --no-cpu-throttling \
  --region asia-southeast1 \
  --timeout=600

echo "Deployment complete!"
echo "The service is now available at: $(gcloud run services describe ollama-backend --region asia-southeast1 --format='value(status.url)')"