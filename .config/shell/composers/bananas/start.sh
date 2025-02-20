#!/bin/bash

# Create shared directories for volumes
mkdir -p automatic1111/extensions automatic1111/models automatic1111/outputs automatic1111/repositories
mkdir -p comfyui/custom_nodes comfyui/models comfyui/output comfyui/workflows
mkdir -p ollama open-webui

# Set correct permissions to avoid permission issues inside containers
sudo chown -R $USER:$USER automatic1111 comfyui ollama open-webui
sudo chmod -R 755 automatic1111 comfyui ollama open-webui

# Start containers in detached mode
docker compose up -d

# Optionally, wait a bit or check container status if needed
sleep 5

# Display the custom message with URLs
echo "---------------------------------------------------"
echo "All services are now running!"
echo "Automatic1111 WebUI: http://localhost:${AUTOMATIC_PORT:-7860}"
echo "ComfyUI: http://localhost:${COMFYUI_PORT:-7860}"
echo "Ollama: http://localhost:${OLLAMA_PORT:-11434}"
echo "Open-webui: http://localhost:${WEBUI_PORT:-3000}"
echo "---------------------------------------------------"
