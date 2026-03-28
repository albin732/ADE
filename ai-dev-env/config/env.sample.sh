# =========================
# ADE ENV SAMPLE
# =========================

# --- Optional (Cloud) ---
# export OPENROUTER_API_KEY="your_key_here"

# # --- Cloud models ---
# export ADE_MODEL_CLOUD_REASON="openrouter/deepseek/deepseek-chat"
# export ADE_MODEL_CLOUD_FAST="openrouter/qwen/qwen-2.5-coder-32b-instruct"
# Python runtime mode

# --- Ollama ---
export ADE_MODEL_MAIN="ollama/qwen2.5-coder:7b"
export ADE_MODEL_LOCAL="ollama/deepseek-coder:6.7b"
export ADE_MODEL_FAST="ollama/deepseek-coder:6.7b"

export AIDER_MODEL="ollama/deepseek-coder:6.7b"
export AIDER_API_BASE="http://localhost:11434"
export AIDER_MAP_TOKENS=1024
export AIDER_API_KEY="ollama=dummy"

# Preferred version (future switch)
export ADE_PYTHON_VERSION="3.11"

# --- Runtime ---
# Python runtime mode
export ADE_RUNTIME_MODE="auto"   # auto | system | managed

# ADE paths
export ADE_BASE="$HOME/path/to/ADE"
export ADE_PROJECTS="$ADE_BASE/projects"
export ADE_SCRIPTS="$ADE_BASE/ai-dev-env/scripts"


# --- Permissions ---
export ADE_ALLOW_TEST_GEN=true
export ADE_ALLOW_FILE_CREATE=true
export ADE_ALLOW_LINT=true
export ADE_ALLOW_BUG_FIX=true
export AIDER_EDIT_FORMAT=diff
export AIDER_AUTO_COMMITS=false

