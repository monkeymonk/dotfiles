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

# Download and extract the latest stable-diffusion-webui code
RUN wget -O stable-diffusion-webui.tar.gz https://github.com/AUTOMATIC1111/stable-diffusion-webui/archive/refs/heads/master.tar.gz \
  && tar -xzf stable-diffusion-webui.tar.gz --strip-components=1 \
  && rm stable-diffusion-webui.tar.gz

# Create a Python virtual environment and install dependencies
RUN python3 -m venv venv && \
  . venv/bin/activate && \
  pip install --upgrade pip && \
  pip install -r requirements.txt

# Create a non-root user and adjust ownership
RUN useradd -m automatic && chown -R automatic:automatic /app
USER automatic

# Expose the web UI port
EXPOSE 7860

# Start the web UI with the desired command-line arguments
CMD ["bash", "webui.sh", "--api", "--listen", "--port", "7860", "--share"]
