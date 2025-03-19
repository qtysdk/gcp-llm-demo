FROM ollama/ollama:0.6.1

# Listen on all interfaces, port 8080
ENV OLLAMA_HOST 0.0.0.0:8080

# Store model weight files in /models
ENV OLLAMA_MODELS /models

# Reduce logging verbosity
ENV OLLAMA_DEBUG true

# CPU specific optimizations
ENV OLLAMA_CPU true

# Never unload model weights from memory
ENV OLLAMA_KEEP_ALIVE -1

# Store the model weights in the container image
# Using a smaller model more suitable for CPU
ENV MODEL gemma3:1b
RUN ollama serve & sleep 5 && ollama pull $MODEL

# Start Ollama
ENTRYPOINT ["ollama", "serve"]
