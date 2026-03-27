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

# --- Model fallback ---
MODEL="${ADE_MODEL_LOCAL:-$ADE_MODEL_FAST}"

INPUT="$1"
TASK="$2"
BASE="$ADE_PROJECTS"

[ -z "$INPUT" ] && echo "Usage: runai <project> [task|chat]" && exit 1

# =========================
# 🧠 MODE DETECTION
# =========================
MODE="auto"
if [[ "$TASK" == "chat" || "$TASK" == "interactive" ]]; then
  MODE="interactive"
  TASK=""
fi

# =========================
# 📂 RESOLVE PATH
# =========================
if [[ "$INPUT" == /* || "$INPUT" == ~* ]]; then
  FULL_PATH=$(realpath "$INPUT")
else
  FULL_PATH=$(realpath "$BASE/$INPUT")
fi

if [ ! -d "$FULL_PATH" ]; then
  echo "❌ Project not found: $FULL_PATH"
  exit 1
fi

cd "$FULL_PATH"

echo "🚀 Running in $(pwd)"

# =========================
# 🧪 ENV SETUP
# =========================
[ ! -d ".git" ] && git init

if [ ! -d ".venv" ]; then
  echo "❌ .venv missing. Recreate project."
  exit 1
fi

source .venv/bin/activate

# =========================
# 📁 ENSURE BASE STRUCTURE
# =========================
mkdir -p tests
touch tests/__init__.py

# =========================
# 📂 FILE COLLECTION (SMART)
# =========================
FILES=""

# --- Global rules ---
FILES="$FILES $ADE_BASE/ai-dev-env/memory/global_rules.md"

# --- Important files ---
[ -f "README_AI.md" ] && FILES="$FILES README_AI.md"
[ -f "manage.py" ] && FILES="$FILES manage.py"

# --- Detect apps dynamically ---
APPS=$(find . -maxdepth 2 -type d -name migrations -exec dirname {} \;)

for app in $APPS; do
  FILES="$FILES $(find "$app" -maxdepth 1 -name '*.py' -type f 2>/dev/null)"
done

# --- Root python files ---
FILES="$FILES $(find . -maxdepth 1 -name '*.py' -type f 2>/dev/null)"

# --- Tests ---
FILES="$FILES $(find tests -name '*.py' -type f 2>/dev/null)"

# =========================
# 🧠 MODEL
# =========================
echo "🧠 Model: $MODEL"

# =========================
# 🎯 TARGET DETECTION (IMPROVED)
# =========================
TARGET_APP=$(echo "$TASK" | grep -oE "(core|orders|[a-z_]+)" | head -n 1)

[ -z "$TARGET_APP" ] && TARGET_APP="relevant module"

# =========================
# 🔐 PERMISSIONS
# =========================
PERMISSION_RULES=""

[[ "$TASK" != *"test"* ]] && PERMISSION_RULES+="\n- Do NOT create test files"

[ "$ADE_ALLOW_FILE_CREATE" != "true" ] && PERMISSION_RULES+="\n- Do NOT create new files"
[ "$ADE_ALLOW_BUG_FIX" != "true" ] && PERMISSION_RULES+="\n- Do NOT modify code"

PERMISSION_RULES+="\n- Modify only relevant files"
PERMISSION_RULES+="\n- Avoid global changes"
PERMISSION_RULES+="\n- Do NOT duplicate models, urls, AppConfig"

# =========================
# 💬 INTERACTIVE
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

[ -z "$TASK" ] && TASK="Improve project structure with best practices"

INITIAL_PROMPT="$TASK

STRICT:
- Work ONLY on relevant files
- Do NOT break working code
- Do NOT rewrite entire project
- Minimal changes only

Focus:
$TARGET_APP

$PERMISSION_RULES
"

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
# 🔁 SMART LOOP (IMPROVED)
# =========================
echo "🔁 Loop mode"

LAST_ERROR=""

for ((i=1; i<=3; i++)); do
  echo "🧪 Iteration $i"

  python manage.py makemigrations > /dev/null 2>&1
  python manage.py migrate > /dev/null 2>&1

  pytest -v > test_output.txt 2>&1

  if [ $? -eq 0 ]; then
    echo "✅ Tests passed"
    break
  fi

  ERROR_OUTPUT=$(tail -n 40 test_output.txt)
  ERROR_HASH=$(echo "$ERROR_OUTPUT" | md5sum)

  if [ "$ERROR_HASH" == "$LAST_ERROR" ]; then
    echo "⚠️ Repeating error. Stopping."
    break
  fi

  LAST_ERROR="$ERROR_HASH"

  echo "❌ Fixing..."

  FIX_PROMPT="Fix ONLY failing issue.

Error:
$ERROR_OUTPUT

STRICT:
- Fix root cause only
- Do NOT rewrite project
- Modify minimal files
- Avoid duplicate urls/models/apps

If unsure → suggest instead of modifying

$PERMISSION_RULES
"

  "${AIDER_BASE_CMD[@]}" \
    --message "$FIX_PROMPT" \
    --exit \
    $FILES
done

echo "🏁 Done"
