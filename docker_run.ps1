#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Запуск Docker Compose демонстрационного приложения Wiren API

.DESCRIPTION
    Скрипт проверяет наличие Docker, создаёт .env файл при необходимости,
    и запускает приложение через docker compose up --build

.PARAMETER Detached
    Запустить контейнеры в фоновом режиме (detached mode)

.EXAMPLE
    .\docker_run.ps1
    Запуск в обычном режиме с выводом логов

.EXAMPLE
    .\docker_run.ps1 -Detached
    Запуск в фоновом режиме
#>

[CmdletBinding()]
param(
    [Alias("d")]
    [switch]$Detached
)

# Установка кодировки UTF-8 для корректного вывода
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Переход в директорию скрипта
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "🚀 Запуск Wiren API Demo..." -ForegroundColor Cyan
Write-Host ""

# Проверка наличия Docker
Write-Host "Проверка Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker не найден"
    }
    Write-Host "✓ Docker найден: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ ОШИБКА: Docker не установлен или не доступен" -ForegroundColor Red
    Write-Host ""
    Write-Host "Пожалуйста, установите Docker Desktop:" -ForegroundColor Yellow
    Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "ERROR: Docker is not installed or not available" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from the link above." -ForegroundColor Yellow
    exit 1
}

# Проверка наличия Docker Compose
Write-Host "Проверка Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker compose version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose не найден"
    }
    Write-Host "✓ Docker Compose найден: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ ОШИБКА: Docker Compose не доступен" -ForegroundColor Red
    Write-Host ""
    Write-Host "Docker Compose должен быть включён в Docker Desktop." -ForegroundColor Yellow
    Write-Host "Убедитесь, что Docker Desktop запущен." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "ERROR: Docker Compose is not available" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Проверка и создание .env файла
$envFile = Join-Path $ScriptDir ".env"
$envExampleFile = Join-Path $ScriptDir ".env.example"

if (-not (Test-Path $envFile)) {
    if (Test-Path $envExampleFile) {
        Write-Host "📝 Файл .env не найден. Копирование из .env.example..." -ForegroundColor Yellow
        Copy-Item $envExampleFile $envFile
        Write-Host "✓ Файл .env создан из .env.example" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "⚠️  Предупреждение: Файлы .env и .env.example не найдены" -ForegroundColor Yellow
        Write-Host "   Приложение будет использовать значения по умолчанию" -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Host "✓ Файл .env найден" -ForegroundColor Green
    Write-Host ""
}

# Запуск Docker Compose
Write-Host "🐳 Запуск Docker Compose..." -ForegroundColor Cyan
Write-Host ""

if ($Detached) {
    Write-Host "Режим: Фоновый (detached)" -ForegroundColor Yellow
    docker compose up --build -d
} else {
    Write-Host "Режим: С выводом логов (нажмите Ctrl+C для остановки)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Приложение будет доступно по адресам:" -ForegroundColor Green
    Write-Host "  • Клиент:  http://localhost:3000" -ForegroundColor Cyan
    Write-Host "  • Swagger: http://localhost:8080/swagger" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    docker compose up --build
}

# Если запущено в фоновом режиме, вывести информацию после запуска
if ($Detached -and $LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Контейнеры успешно запущены в фоновом режиме" -ForegroundColor Green
    Write-Host ""
    Write-Host "Приложение доступно по адресам:" -ForegroundColor Green
    Write-Host "  • Клиент:  http://localhost:3000" -ForegroundColor Cyan
    Write-Host "  • Swagger: http://localhost:8080/swagger" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Для просмотра логов: docker compose logs -f" -ForegroundColor Yellow
    Write-Host "Для остановки:       docker compose down" -ForegroundColor Yellow
    Write-Host ""
}

exit $LASTEXITCODE
