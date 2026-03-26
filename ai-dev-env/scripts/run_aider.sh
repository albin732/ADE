#!/bin/bash

# =========================
# 🧠 ENV LOAD
# =========================
if [ -z "$ADE_BASE" ]; then
  echo "❌ ADE_BASE not set. Load env first"
  exit 1
fi

source "$ADE_BASE/ai-dev-env/config/env.sh"

# =========================
# ✅ VALIDATION
# =========================
[ -z "$ADE_PROJECTS" ] && echo "❌ ADE_PROJECTS not set" && exit 1
[ -z "$ADE_MODEL_MAIN" ] && echo "❌ Model not set" && exit 1

INPUT="$1"
ARG="$2"
BASE="$ADE_PROJECTS"

[ -z "$INPUT" ] && echo "Usage: runai <project> [task|chat]" && exit 1

# =========================
# 🧠 MODE DETECTION
# =========================
MODE="auto"
if [ "$ARG" == "chat" ] || [ "$ARG" == "interactive" ]; then
  MODE="interactive"
fi

TASK="$ARG"
[ "$MODE" == "interactive" ] && TASK=""

# =========================
# 📂 RESOLVE PROJECT PATH
# =========================
if [[ "$INPUT" == /* || "$INPUT" == ~* ]]; then
  FULL_PATH=$(realpath "$INPUT")
else
  FULL_PATH=$(realpath "$BASE/$INPUT")
fi

if [ ! -d "$FULL_PATH" ]; then
  echo "❌ Project does not exist: $FULL_PATH"
  echo "👉 Use: newproj $INPUT"
  exit 1
fi

cd "$FULL_PATH"

echo "🚀 Running in $(pwd)"

# --- Ensure git ---
[ ! -d ".git" ] && git init

# --- Ensure venv ---
if [ ! -d ".venv" ]; then
  echo "❌ .venv not found"
  exit 1
fi

source .venv/bin/activate

# =========================
# 📁 BASE STRUCTURE (MANDATORY)
# =========================
mkdir -p tests
touch tests/__init__.py

# =========================
# 📂 FILE COLLECTION (GENERIC)
# =========================
FILES=""

# --- Global persistent rules ---
FILES="$FILES $ADE_BASE/ai-dev-env/memory/global_rules.md"

[ -f "README_AI.md" ] && FILES="$FILES README_AI.md"
[ -f "manage.py" ] && FILES="$FILES manage.py"

# --- Detect Django apps ---
APPS=$(find . -maxdepth 2 -type d -name migrations -exec dirname {} \;)

for app in $APPS; do
  FILES="$FILES $(find "$app" -maxdepth 1 -name '*.py' -type f 2>/dev/null)"
done

# --- Root files ---
FILES="$FILES $(find . -maxdepth 1 -name '*.py' -type f 2>/dev/null)"

# --- Tests ---
FILES="$FILES $(find tests -name '*.py' -type f 2>/dev/null)"

# =========================
# 🧠 MODEL ROUTING
# =========================
MODEL="$ADE_MODEL_MAIN"

if [[ "$TASK" == *"fix"* ]] || [[ "$TASK" == *"bug"* ]] || [[ "$TASK" == *"small"* ]]; then
  MODEL="$ADE_MODEL_FAST"
fi

echo "🧠 Model: $MODEL"

# =========================
# 🎯 TARGET APP DETECTION
# =========================
TARGET_APP=$(echo "$TASK" | grep -oE "[a-zA-Z_]+" | head -n 1)

# =========================
# 🔐 PERMISSION CONTROL
# =========================
PERMISSION_RULES=""

[[ "$TASK" != *"test"* ]] && PERMISSION_RULES="$PERMISSION_RULES\n- Do NOT create test files"

[ "$ADE_ALLOW_FILE_CREATE" != "true" ] && PERMISSION_RULES="$PERMISSION_RULES\n- Do NOT create new files"
[ "$ADE_ALLOW_BUG_FIX" != "true" ] && PERMISSION_RULES="$PERMISSION_RULES\n- Do NOT modify code"

PERMISSION_RULES="$PERMISSION_RULES\n- Modify only relevant files"
PERMISSION_RULES="$PERMISSION_RULES\n- Avoid global changes unless required"
PERMISSION_RULES="$PERMISSION_RULES\n- Do NOT modify settings.py unless required"

# =========================
# 💬 INTERACTIVE MODE
# =========================
if [ "$MODE" == "interactive" ]; then
  echo "💬 Interactive mode"

  aider \
    --model "$MODEL" \
    --no-show-model-warnings \
    $FILES

  exit 0
fi

# =========================
# 🤖 AUTO MODE
# =========================
echo "🤖 Auto mode"

# --- Default task ---
if [ -z "$TASK" ]; then
  TASK="Create Django REST API with proper structure"
fi

INITIAL_PROMPT="$TASK

STRICT RULES:
- Only modify relevant app/files
- Do NOT change global config unless necessary
- Do NOT break working features
- Do NOT duplicate:
  - AppConfig
  - models
  - urls

Target:
- Focus only on $TARGET_APP

$PERMISSION_RULES
"

# --- Aider base ---
AIDER_BASE_CMD=(
  aider
  --model "$MODEL"
  --yes
  --no-auto-commit
  --no-show-model-warnings
  --map-tokens 0
)

# =========================
# 🚀 RUN TASK
# =========================
"${AIDER_BASE_CMD[@]}" \
  --message "$INITIAL_PROMPT" \
  --exit \
  $FILES

# =========================
# 🔁 SMART LOOP
# =========================
echo "🔁 Loop mode"

LAST_ERROR=""

for ((i=1; i<=3; i++)); do
  echo "🧪 Iteration $i"

  python manage.py makemigrations > /dev/null 2>&1
  python manage.py migrate > /dev/null 2>&1

  python -m pytest -v > test_output.txt 2>&1

  if [ $? -eq 0 ]; then
    echo "✅ Tests passed"
    break
  fi

  ERROR_OUTPUT=$(tail -n 40 test_output.txt)
  ERROR_HASH=$(echo "$ERROR_OUTPUT" | md5sum)

  if [ "$ERROR_HASH" == "$LAST_ERROR" ]; then
    echo "⚠️ Same error repeating. Stopping loop."
    break
  fi

  LAST_ERROR="$ERROR_HASH"

  echo "❌ Fixing error..."

  FIX_PROMPT="Fix ONLY the failing issue.

Error:
$ERROR_OUTPUT

STRICT:
- Fix only root cause
- Do NOT rewrite project
- Modify only failing app/file
- Avoid duplicate:
  - urls
  - models
  - AppConfig

- If change is risky:
  - Suggest instead of modifying

$PERMISSION_RULES
"

  "${AIDER_BASE_CMD[@]}" \
    --message "$FIX_PROMPT" \
    --exit \
    $FILES
done

echo "🏁 Done"
