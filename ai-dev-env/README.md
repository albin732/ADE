# ⚙️ ADE Internal Documentation

> Technical overview of ADE internals.
> See root README for usage.

---

# 🧠 System Overview

ADE is a script-driven orchestration system combining:

- Aider (editing engine)
- Ollama (LLM backend)
- Bash scripts (control layer)

---

# 🧱 Components

```
ai-dev-env/
├── config/
├── memory/
├── scripts/
└── router/
```

# 📁 Projects Directory

## Location

```text
ADE/projects/
```

---

## Purpose

The `projects/` directory stores all **generated and managed applications**.

Each project is:

```text
✔ isolated
✔ self-contained
✔ AI-managed
```

---

## Structure Example

```text
projects/
└── my_api/
    ├── config/
    ├── core/
    ├── orders/
    ├── tests/
    ├── manage.py
    ├── requirements.txt
    └── .venv/
```

---

## Key Characteristics

- Created via:

  ```bash
  newproj <project_name>
  ```

- Contains:
  - Django project
  - virtual environment (`.venv`)
  - test suite
  - AI-generated code

---

## Behavior in ADE

```text
runai → operates ONLY inside a selected project
```

- No cross-project interaction
- Each project has independent lifecycle

---

## Git Behavior

```text
projects/ is ignored by Git
```

Reasons:

- contains generated code
- includes virtual environments
- includes local databases
- user-specific data

---

## Safety Rules

```text
✔ runai MUST NOT create project implicitly
✔ project must exist before execution
✔ no modification outside selected project
```

---

## Design Intent

The `projects/` folder ensures:

```text
✔ isolation of generated code
✔ reproducible workflows
✔ clean repository (no generated files tracked)
```

---

# ⚙️ Execution Flow

```
runai → run_aider.sh → aider → code → pytest → fix loop
```

---

# 📂 File Selection

- global_rules.md
- project Python files
- detected Django apps
- root configs
- tests

---

# 🔁 Smart Loop

```
run → test → fail → fix → repeat (max 3)
```

---

# 🔐 Permissions

Controlled via env:

```
ADE_ALLOW_TEST_GEN
ADE_ALLOW_FILE_CREATE
ADE_ALLOW_BUG_FIX
```

---

# 🧠 Rules Engine

File:

```
memory/global_rules.md
```

Prevents:

- duplicate AppConfig
- duplicate models
- broken URLs

---

# 📦 Project Creation

Handled by:

```
scripts/create_project.sh
```

---

# 🔀 Router (Optional)

```
scripts/start_router.sh
```

Used for multi-model routing.

---

# ⚠️ Constraints

- no global rewrites
- no hardcoded paths
- no cross-app edits

---

# 🔮 Future

- precision mode
- AST validation
- multi-agent system

---

# 🧠 Philosophy

LLM output is constrained, validated, and test-driven.
