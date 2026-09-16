# build-and-run.ps1
#
# Builds and runs the implementations in this repository.
# A program is only run if its build completes successfully.

$ErrorActionPreference = "Stop"
$RepositoryRoot = $PSScriptRoot

# ------------------------------------------------------------------------------
# BUILD - C IMPLEMENTATION OF "HELLO, WORLD!"
# ------------------------------------------------------------------------------

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "C" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$CSourceDirectory = Join-Path $RepositoryRoot "c"
$CBuildDirectory  = Join-Path $CSourceDirectory "build"

$CBuildSucceeded = $false

Write-Host "[BUILD] Configuring CMake..." -ForegroundColor Yellow

try {
  & cmake -S $CSourceDirectory -B $CBuildDirectory

  if ($LASTEXITCODE -ne 0) {
    throw "CMake configuration exited with code $LASTEXITCODE."
  }

  Write-Host ""
  Write-Host "[BUILD] Building C project..." -ForegroundColor Yellow

  & cmake --build $CBuildDirectory --config Release

  if ($LASTEXITCODE -ne 0) {
    throw "CMake build exited with code $LASTEXITCODE."
  }

  $CBuildSucceeded = $true

  Write-Host ""
  Write-Host "[BUILD] Success." -ForegroundColor Green
} catch {
  Write-Host ""
  Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# RUN - C IMPLEMENTATION OF "HELLO, WORLD!"
# ------------------------------------------------------------------------------

if ($CBuildSucceeded) {
  Write-Host ""
  Write-Host "[RUN] Running C program..." -ForegroundColor Yellow
  Write-Host ""

  $CExecutable = Join-Path $CBuildDirectory "Release\main.exe"
  $ExpectedOutput = "Hello, world!"

  try {
    if (-not (Test-Path $CExecutable)) {
      throw "Executable not found: $CExecutable"
    }

    $COutput = & $CExecutable

    if ($LASTEXITCODE -ne 0) {
      throw "Program exited with code $LASTEXITCODE."
    }

    $COutput | Write-Host
    $ActualOutput = ($COutput | Out-String).Trim()

    if ($ActualOutput -ne $ExpectedOutput) {
      throw "Expected '$ExpectedOutput' but received '$ActualOutput'."
    }

    Write-Host ""
    Write-Host "[RUN] Success." -ForegroundColor Green
  } catch {
    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
  }
} else {
  Write-Host ""
  Write-Host "[RUN] Skipped." -ForegroundColor DarkYellow
}

Write-Host ""

# ------------------------------------------------------------------------------
# BUILD - C++ IMPLEMENTATION OF "HELLO, WORLD!"
# ------------------------------------------------------------------------------

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "C++" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$CppSourceDirectory = Join-Path $RepositoryRoot "cpp"
$CppBuildDirectory  = Join-Path $CppSourceDirectory "build"

$CppBuildSucceeded = $false

Write-Host "[BUILD] Configuring CMake..." -ForegroundColor Yellow

try {
  & cmake -S $CppSourceDirectory -B $CppBuildDirectory

  if ($LASTEXITCODE -ne 0) {
    throw "CMake configuration exited with code $LASTEXITCODE."
  }

  Write-Host ""
  Write-Host "[BUILD] Building C++ project..." -ForegroundColor Yellow

  & cmake --build $CppBuildDirectory --config Release

  if ($LASTEXITCODE -ne 0) {
    throw "CMake build exited with code $LASTEXITCODE."
  }

  $CppBuildSucceeded = $true

  Write-Host ""
  Write-Host "[BUILD] Success." -ForegroundColor Green
} catch {
  Write-Host ""
  Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# RUN - C++ IMPLEMENTATION OF "HELLO, WORLD!"
# ------------------------------------------------------------------------------

if ($CppBuildSucceeded) {
  Write-Host ""
  Write-Host "[RUN] Running C++ program..." -ForegroundColor Yellow
  Write-Host ""

  $CppExecutable = Join-Path $CppBuildDirectory "Release\main.exe"
  $ExpectedOutput = "Hello, world!"

  try {
    if (-not (Test-Path $CppExecutable)) {
      throw "Executable not found: $CppExecutable"
    }

    $CppOutput = & $CppExecutable

    if ($LASTEXITCODE -ne 0) {
      throw "Program exited with code $LASTEXITCODE."
    }

    $CppOutput | Write-Host
    $ActualOutput = ($CppOutput | Out-String).Trim()

    if ($ActualOutput -ne $ExpectedOutput) {
      throw "Expected '$ExpectedOutput' but received '$ActualOutput'."
    }

    Write-Host ""
    Write-Host "[RUN] Success." -ForegroundColor Green
  } catch {
    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
  }
} else {
  Write-Host ""
  Write-Host "[RUN] Skipped." -ForegroundColor DarkYellow
}

Write-Host ""
