# =========================
# 🚀 ADE Setup (Windows)
# =========================

Write-Host "🚀 Setting up ADE..." -ForegroundColor Green
Write-Host ""

# =========================
# 📂 Base Path
# =========================
$ADE_BASE = (Get-Location).Path
Write-Host "📂 ADE_BASE: $ADE_BASE"

# =========================
# 📁 Ensure projects folder
# =========================
New-Item -ItemType Directory -Force -Path "$ADE_BASE\projects" | Out-Null
New-Item -ItemType File -Force -Path "$ADE_BASE\projects\.keep" | Out-Null

# =========================
# ⚙️ Setup env.sh
# =========================
$envFile = "$ADE_BASE\ai-dev-env\config\env.sh"
$sampleFile = "$ADE_BASE\ai-dev-env\config\env.sample.sh"

if (!(Test-Path $envFile)) {
    Copy-Item $sampleFile $envFile
    Write-Host "✅ Created env.sh from sample"
} else {
    Write-Host "ℹ️ env.sh already exists"
}

# =========================
# 🧠 Install aider
# =========================
if (!(Get-Command aider -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Installing aider..."
    pip install aider-chat
} else {
    Write-Host "✅ Aider already installed"
}

# =========================
# 🤖 Check Ollama
# =========================
if (!(Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️ Ollama not found!"
    Write-Host "👉 Install from https://ollama.com"
} else {
    Write-Host "✅ Ollama found"
    Write-Host "💡 Tip: Pull a model manually:"
    Write-Host "   ollama pull <model_name>"
}

# =========================
# 📝 Update PowerShell Profile
# =========================
$profilePath = $PROFILE

if (!(Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$content = Get-Content $profilePath -Raw

if ($content -notmatch "ADE \(AI Dev Environment\)") {

    Add-Content $profilePath "`n# ===== ADE (AI Dev Environment) ====="
    Add-Content $profilePath "`$env:ADE_BASE = `"$ADE_BASE`""
    Add-Content $profilePath 'if (Test-Path "$env:ADE_BASE\ai-dev-env\config\env.sh") {'
    Add-Content $profilePath '  # Note: env.sh is bash-based; recommended to use WSL'
    Add-Content $profilePath '}'
    Add-Content $profilePath 'function runai { & "$env:ADE_BASE\ai-dev-env\scripts\run_aider.sh" $args }'
    Add-Content $profilePath 'function newproj { & "$env:ADE_BASE\ai-dev-env\scripts\create_project.sh" $args }'

    Write-Host "✅ Added ADE to PowerShell profile"
} else {
    Write-Host "ℹ️ ADE already configured"
}

# =========================
# 🔄 Reload profile
# =========================
. $PROFILE

# =========================
# 🎉 Done
# =========================
Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "👉 Next steps:"
Write-Host "1. Pull a model:"
Write-Host "   ollama pull <model_name>"
Write-Host ""
Write-Host "2. Start using ADE:"
Write-Host "   newproj my_api"
Write-Host "   runai my_api"
Write-Host ""
Write-Host "💡 Recommended: Use WSL for full compatibility"
