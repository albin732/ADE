# 🚀 ADE (AI Dev Environment)

![Status](https://img.shields.io/badge/status-active-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-linux%20%7C%20windows-lightgrey)

A **controlled, test-driven AI development environment** for safe and scalable code generation.

Built with:

* 🧠 Aider (code generation & editing)
* 🤖 Ollama (local LLMs)
* ⚙️ Custom orchestration scripts

---

# ⚡ Why ADE?

Unlike typical AI coding tools:

| Tool              | Behavior               |
| ----------------- | ---------------------- |
| Copilot / ChatGPT | Suggest code           |
| ADE               | Builds + tests + fixes |

ADE provides:

* ✔ Controlled edits (no chaos)
* ✔ Test-driven corrections
* ✔ Minimal, scoped changes
* ✔ Safe automation loop

---

# 🧪 Quick Demo

```bash
newproj demo_api
runai demo_api "create Item API"
```

Result:

* Model created
* API endpoints added
* Tests generated
* All tests passing ✅

---

# 🧱 Architecture

```
ADE/
├── ai-dev-env/       # core system
├── projects/         # generated apps (ignored)
├── CONTRIBUTING.md
└── README.md
```

---

## 🧠 Execution Flow

```
User (runai)
   ↓
run_aider.sh
   ↓
Aider (LLM)
   ↓
Code Generation / Edit
   ↓
pytest (test loop)
   ↓
Fix (if needed)
   ↓
Stable Output
```

---

# 🚀 How to Use

---

## 🧠 Setup

```bash
git clone git@github.com:albin732/ADE.git
cd ADE

cp ai-dev-env/config/env.sample.sh ai-dev-env/config/env.sh
```

---

## 🧩 Enable Commands

### 🐧 Linux / macOS

```bash
export ADE_BASE="$HOME/path/to/ADE"
source "$ADE_BASE/ai-dev-env/config/env.sh"

runai() {
  $ADE_BASE/ai-dev-env/scripts/run_aider.sh "$@"
}

newproj() {
  $ADE_BASE/ai-dev-env/scripts/create_project.sh "$1"
}

source ~/.bashrc
```

---

### 🪟 Windows (PowerShell)

```powershell
$env:ADE_BASE="C:\path\to\ADE"

function runai {
    & "$env:ADE_BASE\ai-dev-env\scripts\run_aider.sh" $args
}

function newproj {
    & "$env:ADE_BASE\ai-dev-env\scripts\create_project.sh" $args
}

. $PROFILE
```

> 💡 Windows users: Recommended to use WSL or Git Bash.

---

# ⚙️ Commands

## 📦 Create Project

```bash
newproj my_api
```

---

## 🤖 Run AI

```bash
runai my_api
```

---

## 🎯 Run Task

```bash
runai my_api "create Order API in orders app"
```

---

## 💬 Interactive Mode

```bash
runai my_api chat
```

---

## 🧪 Run Tests

```bash
cd projects/my_api
source .venv/bin/activate
pytest -v
```

---

# 🔁 What Happens Internally

```
1. Load project
2. Send task to AI
3. Generate/update code
4. Run tests
5. Detect failures
6. Fix root cause only
7. Repeat (max 3 times)
```

---

# 🔐 Behavior Control

Edit `env.sh`:

```bash
ADE_ALLOW_TEST_GEN=true
ADE_ALLOW_FILE_CREATE=true
ADE_ALLOW_BUG_FIX=true
```

---

# 📁 Notes

* `projects/` is ignored (local only)
* `env.sh` is private
* Use `env.sample.sh`

---

# 🛠 Troubleshooting

### ❌ Model not found

```bash
ollama serve
```

---

### ❌ Command not found

```bash
source ~/.bashrc
```

---

### ❌ Tests failing repeatedly

```bash
runai my_api chat
```

---

### ❌ Windows issues

Use WSL or Git Bash.

---

# 📚 Documentation

Internal details:

```
ai-dev-env/README.md
```

---

# 🤝 Contributing

See:

```
CONTRIBUTING.md
```

---

# 🔮 Roadmap

* Precision mode (file-level fixes)
* Task templates
* Multi-agent system
* LiteLLM routing

---

# 🚀 Status

```
LEVEL 9: Controlled Autonomous Dev System
```

---

# 💡 Philosophy

> ADE is not AI code generation.
> It is **controlled AI-assisted development**.
