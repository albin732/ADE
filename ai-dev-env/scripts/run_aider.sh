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

MODEL="${ADE_MODEL_LOCAL:-$ADE_MODEL_FAST}"

INPUT="$1"
TASK="$2"
BASE="$ADE_PROJECTS"

[ -z "$INPUT" ] && echo "Usage: runai <project> [task|chat]" && exit 1

# =========================
# 🧠 MODE
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

[ ! -d "$FULL_PATH" ] && echo "❌ Project not found" && exit 1

cd "$FULL_PATH"
PROJECT_ROOT="$(pwd)"

echo "🚀 Running in $PROJECT_ROOT"

# =========================
# 🧪 ENV SETUP
# =========================
[ ! -d ".git" ] && git init

[ ! -d ".venv" ] && echo "❌ .venv missing" && exit 1

source .venv/bin/activate

mkdir -p tests
touch tests/__init__.py

# =========================
# 📂 FILE COLLECTION
# =========================
FILES=""

[ -f ".ai-rules.md" ] && FILES="$FILES .ai-rules.md"
[ -f "README_AI.md" ] && FILES="$FILES README_AI.md"
[ -f "manage.py" ] && FILES="$FILES manage.py"

APPS=$(find . -maxdepth 2 -type d -name migrations -exec dirname {} \;)

for app in $APPS; do
  FILES="$FILES $(find "$app" -maxdepth 1 -name '*.py' -type f 2>/dev/null)"
done

FILES="$FILES $(find . -maxdepth 1 -name '*.py' -type f 2>/dev/null)"
FILES="$FILES $(find tests -name '*.py' -type f 2>/dev/null)"

echo "🧠 Model: $MODEL"

# =========================
# 🎯 TASK TYPE DETECTION
# =========================
TASK_TYPE="feature"

if [[ "$TASK" == *"fix"* ]] || [[ "$TASK" == *"error"* ]] || [[ "$TASK" == *"fail"* ]]; then
  TASK_TYPE="fix"
fi

echo "📌 Task type: $TASK_TYPE"

# =========================
# 🔐 PERMISSIONS
# =========================
PERMISSION_RULES=""

[[ "$TASK" != *"test"* ]] && PERMISSION_RULES+="\n- Do NOT create test files"

PERMISSION_RULES+="
- Modify ONLY relevant files
- Do NOT create files outside project
- Do NOT use ../ paths
- Do NOT duplicate models, urls, AppConfig
- Do NOT create dummy models (e.g., SampleModel)
- If unclear → STOP and explain
"

# =========================
# 💬 INTERACTIVE
# =========================
if [ "$MODE" == "interactive" ]; then
  aider --model "$MODEL" --no-show-model-warnings $FILES
  exit 0
fi

# =========================
# 🤖 AUTO MODE
# =========================
echo "🤖 Auto mode"

[ -z "$TASK" ] && TASK="Improve project safely"

# =========================
# 🧠 PROMPT SELECTION
# =========================
if [ "$TASK_TYPE" == "feature" ]; then

INITIAL_PROMPT="$TASK

PROJECT ROOT:
$PROJECT_ROOT

THIS IS A FEATURE TASK.

STRICT:
- Build real functionality
- Create proper Django app if needed
- Use Django best practices
- DO NOT create dummy models
- DO NOT create placeholder code
- DO NOT satisfy tests artificially
- DO NOT rewrite entire project

REQUIREMENTS:
- Implement full feature properly
- Add serializers, views, urls if needed
- Add meaningful tests

$PERMISSION_RULES
"

else

INITIAL_PROMPT="$TASK

PROJECT ROOT:
$PROJECT_ROOT

THIS IS A FIX TASK.

STRICT:
- Fix root cause only
- DO NOT create dummy models
- DO NOT rewrite project
- Minimal changes only

$PERMISSION_RULES
"

fi

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
# 🔁 LOOP ONLY FOR FIX TASK
# =========================
if [ "$TASK_TYPE" != "fix" ]; then
  echo "⏭ Skipping loop (feature task)"
  exit 0
fi

echo "🔁 Loop mode"

LAST_ERROR=""

for ((i=1; i<=3; i++)); do
  echo "🧪 Iteration $i"

  python manage.py makemigrations > /dev/null 2>&1
  python manage.py migrate > /dev/null 2>&1

  pytest -v > test_output.txt 2>&1

  [ $? -eq 0 ] && echo "✅ Tests passed" && break

  ERROR_OUTPUT=$(tail -n 40 test_output.txt)
  ERROR_HASH=$(echo "$ERROR_OUTPUT" | md5sum)

  [ "$ERROR_HASH" == "$LAST_ERROR" ] && echo "⚠️ Repeating error" && break

  LAST_ERROR="$ERROR_HASH"

  FIX_PROMPT="Fix failing tests ONLY.

Error:
$ERROR_OUTPUT

STRICT:
- Fix root cause only
- DO NOT create dummy models
- DO NOT fake solutions
- Minimal change only
"

  "${AIDER_BASE_CMD[@]}" \
    --message "$FIX_PROMPT" \
    --exit \
    $FILES
done

echo "🏁 Done"
