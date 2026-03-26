# 🚀 ADE (AI Dev Environment)

A **controlled, local autonomous coding system** built with:

- 🧠 Aider (code generation & editing)
- 🤖 Ollama (local LLMs)
- ⚙️ Custom orchestration scripts

ADE enables **safe, test-driven AI development** with strict control over changes.

---

# 🎯 Purpose

ADE is designed to:

- Automate backend/API development
- Generate + test + fix code autonomously
- Prevent unsafe global rewrites
- Maintain deterministic, production-friendly behavior

---

# 🧱 Architecture

```
ADE/
├── ai-dev-env/
│   ├── config/        # env configs (ignored)
│   ├── memory/        # global AI rules
│   ├── scripts/       # core automation
│   └── router/        # (future use)
│
├── projects/          # generated projects (ignored)
│   └── .keep
│
├── .gitignore
└── README.md
```

---

# ⚙️ Core Features

### 🤖 Autonomous Coding

- Generates Django APIs
- Creates models, serializers, views
- Builds test cases

---

### 🔁 Smart Loop (Self-Healing)

- Runs pytest
- Detects failures
- Fixes only root cause
- Stops on repeated errors

---

### 🎯 Scoped Editing (Safe AI)

- Edits only relevant files
- Avoids breaking working code
- Prevents full project rewrites

---

### 🔐 Permission System

Control behavior via env:

```
ADE_ALLOW_TEST_GEN=true
ADE_ALLOW_FILE_CREATE=true
ADE_ALLOW_BUG_FIX=true
```

---

### 🧠 Global Rule Engine

Located at:

```
ai-dev-env/memory/global_rules.md
```

Ensures:

- No duplicate AppConfig
- No broken URLs
- No partial implementations
- Clean Django structure

---

# 🛠 Installation

## 1. Clone repo

```
git clone git@github.com:albin732/ADE.git
cd ADE
```

---

## 2. Install dependencies

### Ollama

Install from: https://ollama.com

```
ollama pull qwen2.5-coder:7b
```

---

### Aider

```
pip install aider-chat
```

---

## 3. Setup environment

```
cp ai-dev-env/config/env.sample.sh ai-dev-env/config/env.sh
```

Edit values inside `env.sh`.

---

## 4. Add aliases

Add to `~/.bashrc`:

```
export ADE_BASE="$HOME/path/to/ADE"
source "$ADE_BASE/ai-dev-env/config/env.sh"

runai() {
  $ADE_BASE/ai-dev-env/scripts/run_aider.sh "$@"
}

newproj() {
  $ADE_BASE/ai-dev-env/scripts/create_project.sh "$1"
}
```

```
source ~/.bashrc
```

---

# 🚀 Usage

## 📦 Create project

```
newproj my_api
```

---

## 🤖 Run AI

```
runai my_api
```

---

## 🎯 Run specific task

```
runai my_api "create Order API in orders app"
```

---

## 💬 Interactive mode

```
runai my_api chat
```

---

# 🧪 Testing

```
cd projects/my_api
source .venv/bin/activate
pytest -v
```

---

# 📁 Projects Folder

`projects/` is **ignored by Git**.

Contains:

- Generated code
- Virtual environments
- Databases

This keeps the repo clean and lightweight.

---

# 🔐 Environment Files

Real env file is ignored:

```
ai-dev-env/config/env.sh
```

Use sample:

```
ai-dev-env/config/env.sample.sh
```

---

# ⚠️ Design Principles

- ❌ No blind generation

- ❌ No global rewrites

- ❌ No duplicate structures

- ✅ Minimal edits

- ✅ Test-driven fixes

- ✅ App-level isolation

- ✅ Deterministic behavior

---

# 📁 Key Scripts

### run_aider.sh

- Executes AI tasks
- Handles loop + fixes
- Enforces rules

---

### create_project.sh

- Creates Django project
- Sets up environment

---

### env.sh

- Central configuration
- Models + permissions

---

# 🔮 Roadmap

- Precision mode (file-level edits)
- Task templates
- Multi-agent system
- LiteLLM routing
- Debug dashboard

---

# 🚀 Current Status

```
LEVEL 8: Controlled Autonomous Dev System
```

---

# 🤝 Contributing

- Keep changes minimal
- Follow global rules
- Avoid breaking structure

---

# 📜 License

MIT

---

# 💡 Note

ADE is not just AI coding —
it’s a **controlled development system** built for reliability.
