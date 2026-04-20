# Installs ACC agents to ~/.copilot/agents/ so they're available in every VS Code workspace.
# Run from any directory: powershell -ExecutionPolicy Bypass -File scripts\install-copilot-global.ps1

$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path.Replace('\', '/')
$sourceDir = "$PSScriptRoot\..\..github\agents"
$targetDir = "$env:USERPROFILE\.copilot\agents"

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

Get-ChildItem "$PSScriptRoot\..\.github\agents\*.agent.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace 'references/wiki/', "$repoRoot/references/wiki/"
    $content = $content -replace 'skills/acc-wiki-map/references/', "$repoRoot/skills/acc-wiki-map/references/"
    $outPath = Join-Path $targetDir $_.Name
    Set-Content -Path $outPath -Value $content -NoNewline -Encoding UTF8
    Write-Host "Installed: $($_.Name)"
}

Write-Host ""
Write-Host "ACC agents installed to: $targetDir"
Write-Host "Restart VS Code to pick up the changes."
