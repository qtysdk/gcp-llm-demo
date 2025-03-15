#!/usr/bin/env python3
"""
Project setup script for GCP LLM Demo
This script helps set up the necessary GCP resources for the LLM demo project.
"""

import subprocess
import sys
import os

def run_command(command, exit_on_error=True):
    """Run a shell command and return the result"""
    print(f"Running: {command}")
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        print(e.stderr)
        if exit_on_error:
            sys.exit(1)
        return False

def get_project_id():
    """Get the current GCP project ID"""
    try:
        result = subprocess.run(['gcloud', 'config', 'get-value', 'project'], 
                               check=True, capture_output=True, text=True)
        project_id = result.stdout.strip()
        if not project_id:
            print("No project ID found. Please set a default project with:")
            print("  gcloud config set project YOUR_PROJECT_ID")
            sys.exit(1)
        return project_id
    except subprocess.CalledProcessError as e:
        print(f"Error getting project ID: {e}")
        sys.exit(1)

def enable_apis():
    """Enable required GCP APIs"""
    print("Enabling required APIs...")
    apis = [
        "artifactregistry.googleapis.com",
        "cloudbuild.googleapis.com",
        "run.googleapis.com",
        "storage.googleapis.com"
    ]
    
    command = f"gcloud services enable {' '.join(apis)}"
    return run_command(command)

def create_artifact_registry():
    """Create Artifact Registry repository"""
    print("Creating Artifact Registry repository...")
    command = "gcloud artifacts repositories create llm-models --repository-format=docker --location=asia-southeast1"
    return run_command(command, exit_on_error=False)

def check_gpu_quota():
    """Check if GPU quota is available"""
    print("Checking GPU quota...")
    print("NOTE: This is a basic check and may not be accurate.")
    print("If deployment fails due to quota issues, please request quota for:")
    print("  'Total Nvidia L4 GPU allocation, per project per region' under Cloud Run Admin API")
    print("  in the asia-southeast1 region.")

def print_next_steps(project_id):
    """Print next steps for the user"""
    print("\nSetup completed! Next steps:")
    print("  1. Review and edit files in the project directory if needed")
    print(f"  2. Build the container: gcloud builds submit --config=cloudbuild.yaml")
    print("  3. Deploy to Cloud Run: ./deploy.sh")

if __name__ == "__main__":
    # Get project ID
    project_id = get_project_id()
    print(f"Setting up GCP LLM Demo in project: {project_id}")
    
    # Enable APIs
    enable_apis()
    
    # Create Artifact Registry repository
    create_artifact_registry()
    
    # Check GPU quota
    check_gpu_quota()
    
    # Print next steps
    print_next_steps(project_id)