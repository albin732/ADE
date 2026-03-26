#!/bin/bash

# --- Load env ---
source "$HOME/hub/00_own/ADE/ai-dev-env/config/env.sh"

# --- Validate input ---
PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Usage: newproj <project_name>"
  exit 1
fi

# --- Validate env ---
if [ -z "$ADE_PROJECTS" ]; then
  echo "❌ ADE_PROJECTS not set"
  exit 1
fi

PROJECT_PATH="$ADE_PROJECTS/$PROJECT_NAME"

echo "🚀 Creating project: $PROJECT_NAME"

# --- Create directories ---
mkdir -p "$PROJECT_PATH"

# --- Enter project ---
cd "$PROJECT_PATH" || {
  echo "❌ Failed to enter project directory"
  exit 1
}

# --- Safety check ---
if [[ "$(pwd)" == "$HOME" ]]; then
  echo "❌ Safety stop: running in HOME directory!"
  exit 1
fi

# --- Create venv ---
python3 -m venv .venv
source .venv/bin/activate

# --- Install deps ---
pip install django djangorestframework pytest pytest-django

# --- Create Django project ---
django-admin startproject config .

# --- Create app ---
python manage.py startapp core

# --- Clean tests ---
mkdir tests
touch tests/__init__.py
rm -rf core/tests 2>/dev/null
rm core/tests.py 2>/dev/null

# --- AI context ---
cat <<EOF > .ai-context.md
# Project Context

## Tech Stack
- Python
- Django
- Django REST Framework
- Pytest

## Goal
Build a clean REST API with proper models, serializers, and tests.

## Rules
- Keep code simple and readable
- Follow PEP8
- Do NOT over-engineer
- Always write tests for new features

## Structure
- Models → core/models.py
- Views → core/views.py
- Serializers → core/serializers.py
- Tests → /tests
EOF

# --- README ---
cat <<EOF > README_AI.md
# AI Instructions

- Always write tests with features
- Keep code minimal and clean
- Avoid unnecessary complexity
EOF

# --- Pytest config ---
cat <<EOF > pytest.ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings
python_files = tests.py test_*.py *_tests.py
EOF

# --- Freeze deps ---
pip freeze > requirements.txt

# --- Git init ---
git init
echo ".venv" >> .gitignore

echo "✅ Project $PROJECT_NAME ready!"
echo "📂 Location: $PROJECT_PATH"
echo "👉 Next: runai $PROJECT_NAME"
