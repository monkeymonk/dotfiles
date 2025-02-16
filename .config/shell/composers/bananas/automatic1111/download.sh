#!/bin/bash

# TODO: handle extensions with this download.sh script

set -euxo pipefail

gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

mkdir -p /home/runner/stable-diffusion-webui/repositories
cd /home/runner/stable-diffusion-webui/repositories

$gcs https://github.com/Stability-AI/stablediffusion.git stable-diffusion-stability-ai
$gcs https://github.com/Stability-AI/generative-models.git generative-models
$gcs https://github.com/CompVis/taming-transformers.git taming-transformers
$gcs https://github.com/crowsonkb/k-diffusion.git k-diffusion
$gcs https://github.com/sczhou/CodeFormer.git CodeFormer
$gcs https://github.com/salesforce/BLIP.git BLIP
$gcs https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git stable-diffusion-webui-assets

mkdir -p /home/runner/stable-diffusion-webui/extensions
cd /home/runner/stable-diffusion-webui/extensions

$gcs https://github.com/Mikubill/sd-webui-controlnet.git controlnet
$gcs https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git images-browser
$gcs https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git tag-autocomplete
$gcs https://github.com/toshiaki1729/stable-diffusion-webui-text2prompt.git text2prompt

# cd /home/runner/stable-diffusion-webui
# aria2c --allow-overwrite=false --auto-file-renaming=false --continue=true \
#   --max-connection-per-server=5 --input-file=/home/scripts/download.txt
