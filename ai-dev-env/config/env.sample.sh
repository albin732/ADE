# =========================
# ADE ENV SAMPLE
# =========================

export ADE_BASE="$HOME/path/to/ADE"
export ADE_PROJECTS="$ADE_BASE/projects"
export ADE_SCRIPTS="$ADE_BASE/ai-dev-env/scripts"

# --- Local models ---
export ADE_MODEL_MAIN="ollama/qwen2.5-coder:7b"
export ADE_MODEL_FAST="ollama/deepseek-coder:6.7b"

# --- Permissions ---
export ADE_ALLOW_TEST_GEN=true
export ADE_ALLOW_FILE_CREATE=true
export ADE_ALLOW_BUG_FIX=true

# --- Ollama ---
export OLLAMA_API_BASE="http://localhost:11434"

# --- Optional (Cloud) ---
# export OPENROUTER_API_KEY="your_key_here"

# # --- Cloud models ---
# export ADE_MODEL_CLOUD_REASON="openrouter/deepseek/deepseek-chat"
# export ADE_MODEL_CLOUD_FAST="openrouter/qwen/qwen-2.5-coder-32b-instruct"
