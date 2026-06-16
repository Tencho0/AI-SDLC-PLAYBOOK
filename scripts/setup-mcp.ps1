#requires -Version 5.1
<#
.SYNOPSIS
  Generate a local .mcp.json for this engagement from .mcp.json.example + .env.

.DESCRIPTION
  Reads credential values from .env, substitutes them into the committed
  .mcp.json.example structure, and writes a gitignored .mcp.json. Any server
  whose required ${VAR} secret is absent from .env is dropped, so unconfigured
  servers never half-start. Servers that need no secret (atlassian, figma,
  playwright) are always kept and authenticate via browser OAuth / no auth on
  first use.

.NOTES
  Run from anywhere:  powershell -File scripts\setup-mcp.ps1
  Both .env and .mcp.json are gitignored - secrets are never committed (guardrail 6).
  Re-run whenever you change .env. Restart the Claude session (or reload the
  window) afterwards so the new .mcp.json is picked up.
#>
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
$Root    = Split-Path -Parent $ScriptDir
$EnvFile = Join-Path $Root '.env'
$Example = Join-Path $Root '.mcp.json.example'
$OutFile = Join-Path $Root '.mcp.json'

function Read-DotEnv($path) {
  $map = @{}
  foreach ($line in Get-Content $path) {
    $t = $line.Trim()
    if ($t -eq '' -or $t.StartsWith('#')) { continue }
    $eq = $t.IndexOf('=')
    if ($eq -lt 1) { continue }
    $k = $t.Substring(0, $eq).Trim()
    $v = $t.Substring($eq + 1).Trim().Trim('"').Trim("'")
    if ($v -ne '') { $map[$k] = $v }
  }
  return $map
}

if (-not (Test-Path $Example)) { Write-Error "Missing template: $Example"; exit 1 }
if (-not (Test-Path $EnvFile)) {
  Write-Host "No .env found at $EnvFile" -ForegroundColor Yellow
  Write-Host "Create one from the template, fill it in, then re-run:" -ForegroundColor Yellow
  Write-Host "  Copy-Item mcp.env.example .env" -ForegroundColor Yellow
  exit 1
}

$vars = Read-DotEnv $EnvFile
$json = (Get-Content $Example -Raw) | ConvertFrom-Json

$kept = @(); $dropped = @()
foreach ($name in @($json.mcpServers.PSObject.Properties.Name)) {
  $serverText = $json.mcpServers.$name | ConvertTo-Json -Depth 20
  $needed  = @([regex]::Matches($serverText, '\$\{(\w+)\}') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
  $missing = @($needed | Where-Object { -not $vars.ContainsKey($_) })
  if ($missing.Count -gt 0) {
    $json.mcpServers.PSObject.Properties.Remove($name)
    $dropped += [pscustomobject]@{ Server = $name; Missing = ($missing -join ', ') }
  } else {
    $kept += $name
  }
}

$out = $json | ConvertTo-Json -Depth 20
$out = [regex]::Replace($out, '\$\{(\w+)\}', {
  param($m)
  $key = $m.Groups[1].Value
  if ($vars.ContainsKey($key)) { $vars[$key] } else { $m.Value }
})

[System.IO.File]::WriteAllText($OutFile, $out, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ""
Write-Host "Wrote $OutFile" -ForegroundColor Green
if ($kept.Count -gt 0) {
  Write-Host "Active servers: $($kept -join ', ')" -ForegroundColor Green
} else {
  Write-Host "No servers active - .env has no credentials filled in." -ForegroundColor Yellow
}
if ($dropped.Count -gt 0) {
  Write-Host "Skipped (missing creds in .env):" -ForegroundColor Yellow
  foreach ($d in $dropped) { Write-Host "  - $($d.Server)  (needs: $($d.Missing))" -ForegroundColor Yellow }
}
Write-Host ""
Write-Host "Reminders:" -ForegroundColor Cyan
Write-Host "  - ado needs 'az login'; github uses your PAT as a Bearer header (no Docker)."
Write-Host "  - atlassian / figma open a browser OAuth flow on first use."
Write-Host "  - Restart the Claude session (or reload the window) to pick up the new .mcp.json."
