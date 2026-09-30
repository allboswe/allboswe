$ErrorActionPreference = "Stop"

$RepositoryRoot = $PSScriptRoot
$ExpectedOutput = "Hello, world!"

# ------------------------------------------------------------------------------
# CMake: Build and run CMake projects.
# ------------------------------------------------------------------------------

function Invoke-CMakeProject {
  param (
    [Parameter(Mandatory)]
    [string]$Language,
    [Parameter(Mandatory)]
    [string]$Directory
  )

  Write-Host ""
  Write-Host "===========================================" -ForegroundColor Cyan
  Write-Host $Language -ForegroundColor Cyan
  Write-Host "===========================================" -ForegroundColor Cyan
  Write-Host ""

  $SourceDirectory = Join-Path $RepositoryRoot $Directory
  $BuildDirectory = Join-Path $SourceDirectory "build"
  $Executable = Join-Path $BuildDirectory "Release\main.exe"

  $BuildSucceeded = $false

  # ----------------------------------------------------------------------------
  # Build CMake project.
  # ----------------------------------------------------------------------------

  Write-Host "[BUILD] Configuring CMake..." -ForegroundColor Yellow

  try {
    & cmake -S $SourceDirectory -B $BuildDirectory

    if ($LASTEXITCODE -ne 0) {
      throw "CMake configuration exited with code $LASTEXITCODE."
    }

    Write-Host ""
    Write-Host "[BUILD] Building $Language project..." -ForegroundColor Yellow

    & cmake --build $BuildDirectory --config Release

    if ($LASTEXITCODE -ne 0) {
      throw "CMake build exited with code $LASTEXITCODE."
    }

    $BuildSucceeded = $true

    Write-Host ""
    Write-Host "[BUILD] Success." -ForegroundColor Green
  } catch {
    Write-Host ""
    Write-Host "[BUILD] Failed." -ForegroundColor Red
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
  }

  # ----------------------------------------------------------------------------
  # Run CMake project.
  # ----------------------------------------------------------------------------

  if (-not $BuildSucceeded) {
    Write-Host ""
    Write-Host "[RUN] Skipped." -ForegroundColor DarkYellow
    Write-Host ""

    return
  }

  Write-Host ""
  Write-Host "[RUN] Running $Language program..." -ForegroundColor Yellow
  Write-Host ""

  try {
    if (-not (Test-Path $Executable)) {
      throw "Executable not found: $Executable."
    }

    $Output = & $Executable

    if ($LASTEXITCODE -ne 0) {
      throw "Program exited with code $LASTEXITCODE."
    }

    $Output | Write-Host
    $ActualOutput = ($Output | Out-String).Trim()

    if ($ActualOutput -ne $ExpectedOutput) {
      throw "Expected '$ExpectedOutput' but received '$ActualOutput'."
    }

    Write-Host ""
    Write-Host "[RUN] Success." -ForegroundColor Green
  } catch {
    Write-Host ""
    Write-Host "[RUN] Failed." -ForegroundColor Red
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
  }

  Write-Host ""
}

# ------------------------------------------------------------------------------
# CMake: Execute CMake projects.
# ------------------------------------------------------------------------------

Invoke-CMakeProject -Language "C"   -Directory "c"
Invoke-CMakeProject -Language "C++" -Directory "cpp"
