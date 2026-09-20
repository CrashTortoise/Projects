[CmdletBinding()]
param(
    [ValidateRange(1024, 65535)]
    [int]$Port = 8080,

    [switch]$AllowLAN,

    [switch]$NoBrowser
)

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$browserUrl = "http://127.0.0.1:$Port"
$listenAddress = if ($AllowLAN) { '0.0.0.0' } else { '127.0.0.1' }
$databasePath = Join-Path $projectRoot 'data\project-tab.db'
$bundledNode = Join-Path $projectRoot 'runtime\node.exe'

if (Test-Path -LiteralPath $bundledNode) {
    $nodePath = $bundledNode
} else {
    $nodeCommand = Get-Command node -ErrorAction SilentlyContinue
    if (-not $nodeCommand) {
        throw 'Node.js 24 or later was not found. Install Node.js, then run Start-Project-TAB.cmd again.'
    }
    $nodePath = $nodeCommand.Source
}

$nodeVersion = (& $nodePath --version).Trim()
if ($LASTEXITCODE -ne 0 -or $nodeVersion -notmatch '^v(?<major>\d+)\.') {
    throw 'The Node.js version could not be determined.'
}
if ([int]$Matches.major -lt 24) {
    throw "Project TAB requires Node.js 24 or later. Found $nodeVersion."
}

try {
    $existing = Invoke-RestMethod -Uri "$browserUrl/api/health" -TimeoutSec 1
    if ($existing.service -eq 'Project TAB') {
        Write-Host "Project TAB is already running at $browserUrl" -ForegroundColor Green
        if (-not $NoBrowser) { Start-Process $browserUrl }
        exit 0
    }
} catch {
    # No existing Project TAB instance responded, so continue with startup.
}

New-Item -ItemType Directory -Path (Split-Path -Parent $databasePath) -Force | Out-Null
$env:HOST = $listenAddress
$env:PORT = [string]$Port
$env:TAB_DB_PATH = $databasePath

Write-Host ''
Write-Host 'Project TAB - Test a Breach' -ForegroundColor Cyan
Write-Host "Runtime:  $nodeVersion"
Write-Host "Database: $databasePath"
Write-Host "Local URL: $browserUrl"

if ($AllowLAN) {
    Write-Host ''
    Write-Host 'LAN access is enabled. Only share the URLs below on a trusted network.' -ForegroundColor Yellow
    try {
        $addresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.IPAddress -notlike '169.254.*' } |
            Select-Object -ExpandProperty IPAddress -Unique
        foreach ($address in $addresses) {
            Write-Host ("Participant URL: http://{0}:{1}" -f $address, $Port)
        }
    } catch {
        Write-Host 'Use this computer''s IPv4 address with the selected port for participant access.'
    }
}

Write-Host ''
Write-Host 'Keep this window open while using Project TAB. Press Ctrl+C to stop it.'
Write-Host ''

$nodeProcess = Start-Process -FilePath $nodePath -ArgumentList 'server.js' -WorkingDirectory $projectRoot -NoNewWindow -PassThru
$ready = $false

try {
    for ($attempt = 0; $attempt -lt 40; $attempt += 1) {
        if ($nodeProcess.HasExited) { break }
        try {
            $health = Invoke-RestMethod -Uri "$browserUrl/api/health" -TimeoutSec 1
            if ($health.service -eq 'Project TAB') {
                $ready = $true
                break
            }
        } catch {
            Start-Sleep -Milliseconds 250
        }
    }

    if (-not $ready) {
        throw "Project TAB did not become ready at $browserUrl. The port may already be in use."
    }

    if (-not $NoBrowser) { Start-Process $browserUrl }
    Wait-Process -Id $nodeProcess.Id
    $nodeProcess.Refresh()
    if ($nodeProcess.ExitCode -ne 0) {
        throw "Project TAB exited with code $($nodeProcess.ExitCode)."
    }
} finally {
    if (-not $nodeProcess.HasExited) {
        Stop-Process -Id $nodeProcess.Id -ErrorAction SilentlyContinue
    }
}
