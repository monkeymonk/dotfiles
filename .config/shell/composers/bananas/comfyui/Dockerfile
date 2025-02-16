FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt-get update && apt-get install -y \
  build-essential \
  ca-certificates \
  git \
  libffi-dev \
  libgl1 \
  libglib2.0-0 \
  libssl-dev \
  python3.10 \
  python3.10-dev \
  python3.10-venv \
  software-properties-common \
  wget \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Make python3 point to Python 3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Clone the ComfyUI repository into /app
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# Create and activate a virtual environment, upgrade pip, and install dependencies
RUN python3 -m venv venv && \
  . venv/bin/activate && \
  pip install --upgrade pip && \
  pip install torch torchvision torchaudio && \
  pip install -r requirements.txt

# Create a non-root user and set permissions
RUN useradd -m comfy && chown -R comfy:comfy /app
USER comfy

# Expose ComfyUI's port
EXPOSE 8188

# Run ComfyUI using the virtual environment's Python interpreter
CMD ["venv/bin/python", "main.py"]
