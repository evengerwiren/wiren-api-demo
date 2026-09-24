#Requires -Version 3.0
<#
.SYNOPSIS
    Runs Wiren API Demo in Docker containers.

.DESCRIPTION
    This script checks Docker and docker compose availability,
    prepares .env file, and starts the application containers.

.PARAMETER Detached
    Run containers in detached mode (background).

.EXAMPLE
    .\docker_run.ps1
    Runs containers in foreground mode.

.EXAMPLE
    .\docker_run.ps1 -Detached
    Runs containers in detached mode.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [Alias("d")]
    [switch]$Detached
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Colors for output
$ColorInfo = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"

# Helper function to write colored output
function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Check if Docker is available
function Test-DockerAvailable {
    try {
        $null = docker --version 2>&1
        return $true
    }
    catch {
        return $false
    }
}

# Check if docker compose is available
function Test-DockerComposeAvailable {
    try {
        $null = docker compose version 2>&1
        return $true
    }
    catch {
        return $false
    }
}

# Main script execution
try {
    Write-ColorOutput "`n========================================" $ColorInfo
    Write-ColorOutput "  Wiren API Demo - Docker Startup" $ColorInfo
    Write-ColorOutput "========================================`n" $ColorInfo

    # Check Docker
    Write-ColorOutput "[1/4] Checking Docker..." $ColorInfo
    if (-not (Test-DockerAvailable)) {
        Write-ColorOutput "ERROR: Docker is not installed or not running." $ColorError
        Write-ColorOutput "Install Docker Desktop: https://www.docker.com/products/docker-desktop" $ColorWarning
        exit 1
    }
    Write-ColorOutput "      Docker found" $ColorSuccess

    # Check docker compose
    Write-ColorOutput "`n[2/4] Checking docker compose..." $ColorInfo
    if (-not (Test-DockerComposeAvailable)) {
        Write-ColorOutput "ERROR: docker compose is not available." $ColorError
        Write-ColorOutput "Update Docker Desktop to the latest version." $ColorWarning
        exit 1
    }
    Write-ColorOutput "      docker compose found" $ColorSuccess

    # Prepare .env file
    Write-ColorOutput "`n[3/4] Preparing .env file..." $ColorInfo
    $envFile = Join-Path $PSScriptRoot ".env"
    $envExampleFile = Join-Path $PSScriptRoot ".env.example"

    if (-not (Test-Path $envFile)) {
        if (Test-Path $envExampleFile) {
            Copy-Item $envExampleFile $envFile
            Write-ColorOutput "      .env created from .env.example" $ColorSuccess
        }
        else {
            Write-ColorOutput "WARNING: .env.example not found." $ColorWarning
            Write-ColorOutput "Continuing without .env file..." $ColorWarning
        }
    }
    else {
        Write-ColorOutput "      .env already exists" $ColorSuccess
    }

    # Start containers
    Write-ColorOutput "`n[4/4] Starting containers..." $ColorInfo
    
    $composeArgs = @("compose", "up", "--build")
    if ($Detached) {
        $composeArgs += "-d"
        Write-ColorOutput "      Mode: background (detached)" $ColorInfo
    }
    else {
        Write-ColorOutput "      Mode: foreground (Ctrl+C to stop)" $ColorInfo
    }

    Write-ColorOutput ""
    $process = Start-Process -FilePath "docker" -ArgumentList $composeArgs -NoNewWindow -Wait -PassThru
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0) {
        Write-ColorOutput "`n========================================" $ColorSuccess
        Write-ColorOutput "  Application started successfully!" $ColorSuccess
        Write-ColorOutput "========================================`n" $ColorSuccess
        
        Write-ColorOutput "Available services:" $ColorInfo
        Write-ColorOutput "  * Client:  http://localhost:3000" $ColorSuccess
        Write-ColorOutput "  * API:     http://localhost:8080/swagger`n" $ColorSuccess
        
        if ($Detached) {
            Write-ColorOutput "To stop, run:" $ColorInfo
            Write-ColorOutput "  docker compose down`n" $ColorWarning
        }
        
        exit 0
    }
    else {
        Write-ColorOutput "`nERROR: Container exited with code $exitCode" $ColorError
        exit $exitCode
    }
}
catch {
    Write-ColorOutput "`nCRITICAL ERROR: $_" $ColorError
    Write-ColorOutput $_.ScriptStackTrace $ColorError
    exit 1
}
