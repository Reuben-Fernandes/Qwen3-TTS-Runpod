# ── Base ─────────────────────────────────────────────────────────
FROM runpod/comfyui:latest

ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

# ── Python Dependencies ──────────────────────────────────────────
# transformers pinned for Qwen TTS compatibility
RUN pip install \
    "huggingface_hub[cli]" \
    hf_transfer \
    "transformers==4.57.3" \
    --quiet

# ── Custom Nodes ─────────────────────────────────────────────────
RUN cd /workspace/runpod-slim/ComfyUI/custom_nodes && \
    git clone https://github.com/city96/ComfyUI-GGUF && \
    git clone https://github.com/kijai/ComfyUI-KJNodes && \
    git clone https://github.com/LAOGOU-666/ComfyUI-LG_SamplingUtils && \
    git clone https://github.com/flybirdxx/ComfyUI-Qwen-TTS

RUN for dir in /workspace/runpod-slim/ComfyUI/custom_nodes/*/; do \
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
