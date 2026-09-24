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
    Write-ColorOutput "[1/4] Proverka Docker..." $ColorInfo
    if (-not (Test-DockerAvailable)) {
        Write-ColorOutput "OSHIBKA: Docker ne ustanovlen ili ne zapushchen." $ColorError
        Write-ColorOutput "Ustanovite Docker Desktop: https://www.docker.com/products/docker-desktop" $ColorWarning
        exit 1
    }
    Write-ColorOutput "      Docker nayden" $ColorSuccess

    # Check docker compose
    Write-ColorOutput "`n[2/4] Proverka docker compose..." $ColorInfo
    if (-not (Test-DockerComposeAvailable)) {
        Write-ColorOutput "OSHIBKA: docker compose ne dostupna." $ColorError
        Write-ColorOutput "Obnovite Docker Desktop do posledney versii." $ColorWarning
        exit 1
    }
    Write-ColorOutput "      docker compose nayden" $ColorSuccess

    # Prepare .env file
    Write-ColorOutput "`n[3/4] Podgotovka .env fayla..." $ColorInfo
    $envFile = Join-Path $PSScriptRoot ".env"
    $envExampleFile = Join-Path $PSScriptRoot ".env.example"

    if (-not (Test-Path $envFile)) {
        if (Test-Path $envExampleFile) {
            Copy-Item $envExampleFile $envFile
            Write-ColorOutput "      .env sozdana iz .env.example" $ColorSuccess
        }
        else {
            Write-ColorOutput "PREDUPREZHDENIE: .env.example ne nayden." $ColorWarning
            Write-ColorOutput "Prodolzhayu bez .env fayla..." $ColorWarning
        }
    }
    else {
        Write-ColorOutput "      .env uzhe sushchestvuet" $ColorSuccess
    }

    # Start containers
    Write-ColorOutput "`n[4/4] Zapusk konteynerov..." $ColorInfo
    
    $composeArgs = @("compose", "up", "--build")
    if ($Detached) {
        $composeArgs += "-d"
        Write-ColorOutput "      Rezhim: fon (detached)" $ColorInfo
    }
    else {
        Write-ColorOutput "      Rezhim: peredny plan (Ctrl+C dlya ostanovki)" $ColorInfo
    }

    Write-ColorOutput ""
    $process = Start-Process -FilePath "docker" -ArgumentList $composeArgs -NoNewWindow -Wait -PassThru
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0) {
        Write-ColorOutput "`n========================================" $ColorSuccess
        Write-ColorOutput "  Prilozhenie zapushcheno uspeshno!" $ColorSuccess
        Write-ColorOutput "========================================`n" $ColorSuccess
        
        Write-ColorOutput "Dostupnye servisy:" $ColorInfo
        Write-ColorOutput "  * Klient:  http://localhost:3000" $ColorSuccess
        Write-ColorOutput "  * API:     http://localhost:8080/swagger`n" $ColorSuccess
        
        if ($Detached) {
            Write-ColorOutput "Dlya ostanovki vypolnite:" $ColorInfo
            Write-ColorOutput "  docker compose down`n" $ColorWarning
        }
        
        exit 0
    }
    else {
        Write-ColorOutput "`nOSHIBKA: Konteyner zavershen s kodom $exitCode" $ColorError
        exit $exitCode
    }
}
catch {
    Write-ColorOutput "`nKRITIChESKAYa OShIBKA: $_" $ColorError
    Write-ColorOutput $_.ScriptStackTrace $ColorError
    exit 1
}
