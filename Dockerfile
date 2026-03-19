# ── Base ─────────────────────────────────────────────────────────
FROM nvidia/cuda:12.6.0-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV PYTHONUNBUFFERED=1

WORKDIR /workspace

# ── System Dependencies ──────────────────────────────────────────
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        python3.12 \
        python3.12-venv \
        python3-pip \
        python3.12-dev \
        git \
        git-lfs \
        ffmpeg \
        curl \
        wget \
        libgl1 \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/lib/python3.12/EXTERNALLY-MANAGED

# ── Python Setup ─────────────────────────────────────────────────
RUN curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && python3.12 /tmp/get-pip.py && rm /tmp/get-pip.py && python3.12 -m pip install --upgrade pip --quiet

# ── PyTorch ──────────────────────────────────────────────────────
RUN pip install torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu126 \
    --quiet

# ── ComfyUI ──────────────────────────────────────────────────────
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
RUN pip install -r /workspace/ComfyUI/requirements.txt --quiet

# ── Python Dependencies ──────────────────────────────────────────
RUN pip install \
    "huggingface_hub[cli]" \
    hf_transfer \
    "transformers==4.57.3" \
    librosa \
    accelerate \
    jupyter \
    --quiet

# ── Custom Nodes ─────────────────────────────────────────────────
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager && \
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
