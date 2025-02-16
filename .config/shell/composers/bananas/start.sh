#!/bin/bash

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
