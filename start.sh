#!/bin/bash
#
# Qwen 3 TTS Pod start script
#

set -e

COMFYUI_DIR=/workspace/ComfyUI
MIRROR="ReubenF10/ComfyUI-Models"

echo ""
echo "########################################"
echo "#        Qwen 3 TTS - Starting        #"
echo "########################################"
echo ""

if [[ -z "$HF_TOKEN" ]]; then
    echo "ERROR: HF_TOKEN not set. Add it as a RunPod environment variable."
    exit 1
fi

export HF_TOKEN
export HF_HUB_ENABLE_HF_TRANSFER=1

# ── Download Models ──────────────────────────────────────────────
echo "  → Checking models..."

python3 << PYEOF
import os, shutil
from huggingface_hub import hf_hub_download

token = os.environ["HF_TOKEN"]
mirror = "$MIRROR"
base = "$COMFYUI_DIR/models"

models = [
    ("qwen-tts/Qwen/Qwen3-TTS-Tokenizer-12Hz/model.safetensors",        "qwen-tts/Qwen/Qwen3-TTS-Tokenizer-12Hz"),
    ("qwen-tts/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/model.safetensors", "qwen-tts/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign"),
    ("qwen-tts/Qwen/Qwen3-TTS-12Hz-1.7B-Base/model.safetensors",        "qwen-tts/Qwen/Qwen3-TTS-12Hz-1.7B-Base"),
    ("qwen-tts/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice/model.safetensors", "qwen-tts/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice"),
]

for filename, dest_folder in models:
    save_name = filename.split("/")[-1]
    dest = os.path.join(base, dest_folder, save_name)

    if os.path.exists(dest):
        print(f"  ⏭  Already exists: {dest_folder}")
        continue

    os.makedirs(os.path.join(base, dest_folder), exist_ok=True)
    print(f"  → Downloading: {dest_folder}")
    path = hf_hub_download(
        repo_id=mirror,
        filename=filename,
        token=token,
        local_dir="/tmp/hf_dl",
        local_dir_use_symlinks=False
    )
    shutil.move(path, dest)
    print(f"  ✓ Saved")

print("")
print("✓ All models ready")
PYEOF

# ── Download Workflows ───────────────────────────────────────────
echo "  → Downloading workflows..."
mkdir -p "$COMFYUI_DIR/user/default/workflows"
curl -fsSL https://raw.githubusercontent.com/Reuben-Fernandes/ComfyUI-Workflows/main/Qwen3-TTS.json \
    -o "$COMFYUI_DIR/user/default/workflows/Qwen3-TTS.json" && echo "  ✓ Qwen3-TTS.json" || true

# ── Launch ComfyUI ───────────────────────────────────────────────
echo "  → Launching ComfyUI on port 8188..."
echo ""
exec python3 "$COMFYUI_DIR/main.py" \
    --listen 0.0.0.0 \
    --port 8188
