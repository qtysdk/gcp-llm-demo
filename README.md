# LLM on GCP Cloud Run

This project demonstrates how to deploy LLM models (specifically Gemma) to Google Cloud Platform using Cloud Run. It provides a streamlined setup process and emphasizes CPU-based inference for cost-effectiveness.

## Components

- `Dockerfile`: Container definition based on `ollama/ollama`, configured to serve an LLM.  By default, it pulls the `codellama:7b` model, but you can easily change this.
- `cloudbuild.yaml`: Cloud Build configuration for building and pushing the container image to Artifact Registry.
- `bin/deploy.sh`: Script to deploy the Ollama container to Cloud Run. It configures CPU, memory, concurrency, and other Cloud Run service settings.
- `bin/destroy.sh`: Script to clean up all deployed resources, including the Cloud Run service and the Artifact Registry repository and images. **Use with caution!**
- `scripts/setup_project.py`: Python script to automate initial project setup, including enabling required GCP APIs and creating the Artifact Registry repository.
- `Makefile`: Provides convenient commands for common tasks such as setup, build, deploy, destroy, and cleaning up local files.
- `test_inference.py`: Python script to test the deployed service by sending a request to the `/api/generate` endpoint and streaming the response.

## Setup

1. **Prerequisites:**
   - A Google Cloud Project with billing enabled.
   - The `gcloud` CLI installed and configured to point to your GCP project (`gcloud config set project YOUR_PROJECT_ID`).
   - Docker installed (if you plan to build the image locally).

2. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd gcp-llm-demo
   ```

3. **Set up the project:**
   ```bash
   make setup
   ```
   This command will:
   - Enable the necessary GCP APIs (Artifact Registry, Cloud Build, Cloud Run, Storage).
   - Create an Artifact Registry repository named `llm-models` in the `asia-southeast1` region.

4. **Build the container:**
   ```bash
   make build
   ```
   This command uses Cloud Build to build the container image based on the `Dockerfile` and push it to your Artifact Registry.  **Note:** This process can take 30 minutes or longer due to the model download.

5. **Deploy to Cloud Run:**
   ```bash
   make deploy
   ```
   This command deploys the container to Cloud Run using the `deploy.sh` script.

## Usage

The `Makefile` provides several convenient commands:

- `make setup`: Sets up the project environment.
- `make build`: Builds the container image.
- `make deploy`: Deploys the container to Cloud Run.
- `make describe`: Displays details about the deployed Cloud Run service.
- `make destroy`: **Deletes all project resources.**  Use with extreme caution!
- `make clean`: Cleans up local temporary files.

## Testing

After deploying the service, you can test it using the `test_inference.py` script:

1. **Run the test script:**
   ```bash
   python test_inference.py
   ```
   This script will start a local proxy, send a test inference request to the Cloud Run service, and print the streaming response.

## Customization

- **Model Selection:**  You can change the model used by modifying the `MODEL` environment variable in the `Dockerfile`. Consider smaller models for CPU-based deployments.
- **Cloud Run Configuration:** The `deploy.sh` script configures the Cloud Run service.  Adjust the CPU, memory, and concurrency settings as needed.
- **Region:**  The default region is `asia-southeast1`.  You can modify the `REGION` variable in the `Makefile` and `deploy.sh` to use a different region.

## Prerequisites

- Google Cloud Project with billing enabled.
- `gcloud` CLI installed and configured.

## Notes

- The deployment uses CPU for inference.  Adjust resource allocation (CPU/Memory) in the `deploy.sh` script according to your performance requirements.
- The model weights are included in the container image for faster startup.

## Cleaning Up

To remove all deployed resources and avoid incurring further charges:

```bash
make destroy
```

**WARNING: This command will permanently delete all resources created by this project.  Double-check before running!**

## Additional

Create a proxy and setup it to OpenWebUI:

```
gcloud run services proxy ollama-gemma --region asia-southeast1 --port 11434
```
