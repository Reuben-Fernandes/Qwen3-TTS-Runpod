# ── Base ─────────────────────────────────────────────────────────
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HF_HUB_ENABLE_HF_TRANSFER=1

WORKDIR /workspace

# ── System Dependencies ──────────────────────────────────────────
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        python3.12 \
        python3.12-venv \
        python3-pip \
        git \
        git-lfs \
        ffmpeg \
        libgl1 \
        libglib2.0-0 \
        curl \
        wget \
    && rm -rf /var/lib/apt/lists/*

# ── Python venv ──────────────────────────────────────────────────
RUN python3.12 -m venv /workspace/venv
ENV PATH="/workspace/venv/bin:$PATH"

RUN pip install --upgrade pip --quiet

# ── PyTorch (cu124, lightweight) ─────────────────────────────────
RUN pip install torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu124 \
    --quiet

# ── ComfyUI ──────────────────────────────────────────────────────
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
RUN pip install -r /workspace/ComfyUI/requirements.txt --quiet

# ── Python Dependencies ──────────────────────────────────────────
RUN pip install \
    "huggingface_hub[cli]" \
    hf_transfer \
    "transformers==4.57.3" \
    --quiet

# ── Custom Nodes ─────────────────────────────────────────────────
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager && \
    git clone https://github.com/city96/ComfyUI-GGUF && \
    git clone https://github.com/kijai/ComfyUI-KJNodes && \
    git clone https://github.com/LAOGOU-666/ComfyUI-LG_SamplingUtils && \
    git clone https://github.com/flybirdxx/ComfyUI-Qwen-TTS

RUN for dir in /workspace/ComfyUI/custom_nodes/*/; do \
        if [ -f "$dir/requirements.txt" ]; then \
            pip install -r "$dir/requirements.txt" --quiet || true; \
        fi \
    done

# ── Ports ────────────────────────────────────────────────────────
EXPOSE 8188
EXPOSE 8888

# ── Start Script ─────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
