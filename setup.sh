#!/bin/bash

echo "🚀 Setting up ADE..."

# =========================
# 📂 Base path
# =========================
ADE_BASE="$(pwd)"
echo "📂 ADE_BASE: $ADE_BASE"

# =========================
# 📁 Ensure projects folder
# =========================
mkdir -p "$ADE_BASE/projects"
touch "$ADE_BASE/projects/.keep"

# =========================
# ⚙️ Setup env.sh
# =========================
ENV_FILE="$ADE_BASE/ai-dev-env/config/env.sh"
SAMPLE_FILE="$ADE_BASE/ai-dev-env/config/env.sample.sh"

if [ ! -f "$ENV_FILE" ]; then
  cp "$SAMPLE_FILE" "$ENV_FILE"
  echo "✅ Created env.sh from sample"
else
  echo "ℹ️ env.sh already exists"
fi

# =========================
# 🧠 Install aider
# =========================
if ! command -v aider &> /dev/null; then
  echo "📦 Installing aider..."
  pip install aider-chat
else
  echo "✅ Aider already installed"
fi

# =========================
# 🤖 Check Ollama
# =========================
if ! command -v ollama &> /dev/null; then
  echo "⚠️ Ollama not found!"
  echo "👉 Install from: https://ollama.com"
else
  echo "✅ Ollama found"
  echo "💡 Tip: Pull a model manually using:"
  echo "   ollama pull <model_name>"
fi

# =========================
# 📝 Update .bashrc
# =========================
BASHRC="$HOME/.bashrc"

if ! grep -q "ADE (AI Dev Environment)" "$BASHRC"; then
  echo "" >> "$BASHRC"
  echo "# ===== ADE (AI Dev Environment) =====" >> "$BASHRC"
  echo "export ADE_BASE=\"$ADE_BASE\"" >> "$BASHRC"
  echo "source \"\$ADE_BASE/ai-dev-env/config/env.sh\"" >> "$BASHRC"
  echo "" >> "$BASHRC"
  echo "runai() { \"\$ADE_SCRIPTS/run_aider.sh\" \"\$@\"; }" >> "$BASHRC"
  echo "newproj() { \"\$ADE_SCRIPTS/create_project.sh\" \"\$@\"; }" >> "$BASHRC"
  echo "✅ Added ADE to .bashrc"
else
  echo "ℹ️ ADE already configured in .bashrc"
fi

# =========================
# 🔄 Reload
# =========================
echo ""
echo "🔄 Reloading environment..."
source "$HOME/.bashrc"

# =========================
# 🎉 Done
# =========================
echo ""
echo "🎉 Setup complete!"
echo ""
echo "👉 Next steps:"
echo "1. Pull a model:"
echo "   ollama pull <model_name>"
echo ""
echo "2. Start using ADE:"
echo "   newproj my_api"
echo "   runai my_api"
