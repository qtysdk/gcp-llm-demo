#!/usr/bin/env python3
"""
Test script for LLM inference on Cloud Run
"""

import requests
import json
import subprocess
import time
import sys
import threading
import os

def start_proxy():
    """Start the Cloud Run proxy in a separate thread"""
    command = "gcloud run services proxy ollama-backend --port=8080 --region asia-southeast1"
    print("Starting Cloud Run proxy...")
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return process

def test_inference():
    """Send a test inference request to the Cloud Run service"""
    # Wait for proxy to start
    time.sleep(5)

    # Define the prompt
    prompt = "Why is the sky blue?"
    
    # Define the API request
    url = "http://localhost:8080/api/generate"
    payload = {
        "model": "gemma3:2b",
        "prompt": prompt
    }

    print(f"Sending prompt: '{prompt}'")
    print("Waiting for response (streaming)...\n")
    
    try:
        # Send the request
        response = requests.post(url, json=payload, stream=True)
        
        # Process streaming response
        full_response = ""
        for line in response.iter_lines():
            if line:
                chunk = json.loads(line)
                sys.stdout.write(chunk.get('response', ''))
                sys.stdout.flush()
                full_response += chunk.get('response', '')
                if chunk.get('done', False):
                    break
        
        print("\n\nInference completed successfully!")
        return True
    except Exception as e:
        print(f"Error during inference: {e}")
        return False

if __name__ == "__main__":
    # Start the proxy in a separate process
    proxy_process = start_proxy()
    
    try:
        # Run the test
        success = test_inference()
        
        # Give user a chance to see results before terminating
        if success:
            input("\nPress Enter to terminate the proxy and exit...")
        else:
            print("\nTest failed. Check your deployment and try again.")
            input("Press Enter to terminate the proxy and exit...")
    finally:
        # Clean up the proxy process
        proxy_process.terminate()
        print("Proxy terminated. Goodbye!")

