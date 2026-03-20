# ── Base ─────────────────────────────────────────────────────────
FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV PYTHONUNBUFFERED=1

WORKDIR /workspace

# ── System Dependencies ──────────────────────────────────────────
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        git \
        git-lfs \
        ffmpeg \
        libgl1 \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# ── Python Dependencies ──────────────────────────────────────────
RUN pip install --upgrade pip --quiet && \
    pip install \
        "huggingface_hub[cli]" \
        hf_transfer \
        "transformers==4.57.3" \
        librosa \
        accelerate \
        --quiet

# ── ComfyUI ──────────────────────────────────────────────────────
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
RUN pip install -r /workspace/ComfyUI/requirements.txt --quiet

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
