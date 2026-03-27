#!/bin/bash

# =========================
# 🧠 Load env safely
# =========================
if [ -z "$ADE_BASE" ]; then
  echo "❌ ADE_BASE not set. Load environment first"
  exit 1
fi

ENV_FILE="$ADE_BASE/ai-dev-env/config/env.sh"

if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
else
  echo "❌ env.sh not found"
  exit 1
fi

# =========================
# 📦 Parse arguments
# =========================
PROJECT_NAME="$1"
shift

TYPE="django"   # default

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --type)
      TYPE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# =========================
# ❌ Validate input
# =========================
if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Usage: newproj <project_name> [--type <type>]"
  exit 1
fi

if [ -z "$ADE_PROJECTS" ]; then
  echo "❌ ADE_PROJECTS not set"
  exit 1
fi

PROJECT_PATH="$ADE_PROJECTS/$PROJECT_NAME"

echo "🚀 Creating project: $PROJECT_NAME"
echo "🧠 Type: $TYPE"

# =========================
# 📁 Create directory
# =========================
mkdir -p "$PROJECT_PATH"

cd "$PROJECT_PATH" || {
  echo "❌ Failed to enter project directory"
  exit 1
}

# --- Safety check ---
if [[ "$(pwd)" == "$HOME" ]]; then
  echo "❌ Safety stop: running in HOME directory!"
  exit 1
fi

# =========================
# 🐍 Setup virtualenv
# =========================
python3 -m venv .venv
source .venv/bin/activate

# =========================
# 📦 Framework switch
# =========================
case "$TYPE" in

  django)
    echo "📦 Setting up Django project..."

    pip install django djangorestframework pytest pytest-django

    django-admin startproject config .

    python manage.py startapp core

    mkdir -p tests
    touch tests/__init__.py

    rm -rf core/tests 2>/dev/null
    rm core/tests.py 2>/dev/null
    ;;

  *)
    echo "❌ Unknown project type: $TYPE"
    echo "👉 Supported: django (more coming soon)"
    exit 1
    ;;

esac

# =========================
# 🧠 AI Context
# =========================
cat <<EOF > .ai-context.md
# Project Context

## Type
$TYPE

## Tech Stack
- Python
- $TYPE

## Goal
Build a clean, production-ready backend with tests.

## Rules
- Keep code simple and readable
- Follow best practices
- Always write tests
- Avoid unnecessary changes
EOF

# =========================
# 📄 README for AI
# =========================
cat <<EOF > README_AI.md
# AI Instructions

- Follow project structure
- Write minimal and clean code
- Always include tests
- Do NOT rewrite entire project
EOF

# =========================
# 🧪 Pytest config
# =========================
cat <<EOF > pytest.ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings
python_files = tests.py test_*.py *_tests.py
EOF

# =========================
# 📦 Freeze deps
# =========================
pip freeze > requirements.txt

# =========================
# 🔧 Git init
# =========================
git init
echo ".venv" >> .gitignore

# =========================
# ✅ Done
# =========================
echo ""
echo "✅ Project $PROJECT_NAME ready!"
echo "📂 Location: $PROJECT_PATH"
echo "👉 Run: runai $PROJECT_NAME"
