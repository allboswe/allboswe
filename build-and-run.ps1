$ErrorActionPreference = "Stop"

$Results = @()
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

  $RunStatus = "Skipped"
  $BuildStatus = "Failed"
  $BuildSucceeded = $false

  # ----------------------------------------------------------------------------
  # Build CMake project.
  # ----------------------------------------------------------------------------

  Write-Host "[BUILD] Configuring CMake..." -ForegroundColor Yellow

  try {
    & cmake -S $SourceDirectory -B $BuildDirectory | Out-Host

    if ($LASTEXITCODE -ne 0) {
      throw "CMake configuration exited with code $LASTEXITCODE."
    }

    Write-Host ""
    Write-Host "[BUILD] Building $Language project..." -ForegroundColor Yellow

    & cmake --build $BuildDirectory --config Release | Out-Host

    if ($LASTEXITCODE -ne 0) {
      throw "CMake build exited with code $LASTEXITCODE."
    }

    $BuildStatus = "Success"
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

    return [PSCustomObject]@{
      Run = $RunStatus
      Build = $BuildStatus
      Language = $Language
    }
  }

  $RunStatus = "Failed"

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

    $RunStatus = "Success"

    Write-Host ""
    Write-Host "[RUN] Success." -ForegroundColor Green
  } catch {
    Write-Host ""
    Write-Host "[RUN] Failed." -ForegroundColor Red
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
  }

  Write-Host ""

  return [PSCustomObject]@{
    Run = $RunStatus
    Build = $BuildStatus
    Language = $Language
  }
}

# ------------------------------------------------------------------------------
# .NET: Build and run .NET projects.
# ------------------------------------------------------------------------------

function Invoke-DotNetProject {
  param (
    [Parameter(Mandatory)]
    [string]$Language,
    [Parameter(Mandatory)]
    [string]$Directory,
    [Parameter(Mandatory)]
    [string]$ProjectFile
  )

  Write-Host ""
  Write-Host "===========================================" -ForegroundColor Cyan
  Write-Host $Language -ForegroundColor Cyan
  Write-Host "===========================================" -ForegroundColor Cyan
  Write-Host ""

  $SourceDirectory = Join-Path $RepositoryRoot $Directory
  $ProjectPath = Join-Path $SourceDirectory $ProjectFile

  $RunStatus = "Skipped"
  $BuildStatus = "Failed"
  $BuildSucceeded = $false

  # ----------------------------------------------------------------------------
  # Build .NET project.
  # ----------------------------------------------------------------------------

  Write-Host "[BUILD] Building $Language project..." -ForegroundColor Yellow

  try {
    if (-not (Test-Path $ProjectPath)) {
      throw "Project file not found: $ProjectPath."
    }

    & dotnet build $ProjectPath --configuration Release | Out-Host

    if ($LASTEXITCODE -ne 0) {
      throw ".NET build exited with code $LASTEXITCODE."
    }

    $BuildStatus = "Success"
    $BuildSucceeded = $true

    Write-Host ""
    Write-Host "[BUILD] Success." -ForegroundColor Green
  } catch {
    Write-Host ""
    Write-Host "[BUILD] Failed." -ForegroundColor Red
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
  }

  # ----------------------------------------------------------------------------
  # Run .NET project.
  # ----------------------------------------------------------------------------

  if (-not $BuildSucceeded) {
    Write-Host ""
    Write-Host "[RUN] Skipped." -ForegroundColor DarkYellow
    Write-Host ""

    return [PSCustomObject]@{
      Run = $RunStatus
      Build = $BuildStatus
      Language = $Language
    }
  }

  $RunStatus = "Failed"

  Write-Host ""
  Write-Host "[RUN] Running $Language program..." -ForegroundColor Yellow
  Write-Host ""

  try {
    $Output = & dotnet run `
      --project $ProjectPath `
      --configuration Release `
      --no-build

    if ($LASTEXITCODE -ne 0) {
      throw "Program exited with code $LASTEXITCODE."
    }

    $Output | Write-Host
    $ActualOutput = ($Output | Out-String).Trim()

    if ($ActualOutput -ne $ExpectedOutput) {
      throw "Expected '$ExpectedOutput' but received '$ActualOutput'."
    }

    $RunStatus = "Success"

    Write-Host ""
    Write-Host "[RUN] Success." -ForegroundColor Green
  } catch {
    Write-Host ""
    Write-Host "[RUN] Failed." -ForegroundColor Red
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
  }

  Write-Host ""

  return [PSCustomObject]@{
    Run = $RunStatus
    Build = $BuildStatus
    Language = $Language
  }
}

# ------------------------------------------------------------------------------
# GFortran: Build and run Fortran projects.
# ------------------------------------------------------------------------------

function Invoke-FortranProject {
  param (
    [Parameter(Mandatory)]
    [string]$Language,
    [Parameter(Mandatory)]
    [string]$Directory,
    [Parameter(Mandatory)]
    [string]$SourceFile
  )

  Write-Host ""
  Write-Host "===========================================" -ForegroundColor Cyan
  Write-Host $Language -ForegroundColor Cyan
  Write-Host "===========================================" -ForegroundColor Cyan
  Write-Host ""

  $SourceDirectory = Join-Path $RepositoryRoot $Directory
  $SourcePath = Join-Path $SourceDirectory $SourceFile
  $BuildDirectory = Join-Path $SourceDirectory "build"
  $Executable = Join-Path $BuildDirectory "main.exe"

  $RunStatus = "Skipped"
  $BuildStatus = "Failed"
  $BuildSucceeded = $false

  # ----------------------------------------------------------------------------
  # Build Fortran project.
  # ----------------------------------------------------------------------------

  Write-Host "[BUILD] Building $Language project..." -ForegroundColor Yellow

  try {
    if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
      throw "Source file not found: $SourcePath."
    }

    if (-not (Test-Path -LiteralPath $BuildDirectory)) {
      New-Item -ItemType Directory -Path $BuildDirectory -Force | Out-Null
    }

    # Prevent a previous executable from being mistaken for a new build.
    if (Test-Path -LiteralPath $Executable) {
      Remove-Item -LiteralPath $Executable -Force
    }

    & gfortran -o $Executable $SourcePath | Out-Host

    if ($LASTEXITCODE -ne 0) {
      throw "Fortran compilation exited with code $LASTEXITCODE."
    }

    if (-not (Test-Path -LiteralPath $Executable -PathType Leaf)) {
      throw "Executable not found after compilation: $Executable."
    }

    $BuildStatus = "Success"
    $BuildSucceeded = $true

    Write-Host ""
    Write-Host "[BUILD] Success." -ForegroundColor Green
  } catch {
    Write-Host ""
    Write-Host "[BUILD] Failed." -ForegroundColor Red
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
  }

  # ----------------------------------------------------------------------------
  # Run Fortran project.
  # ----------------------------------------------------------------------------

  if (-not $BuildSucceeded) {
    Write-Host ""
    Write-Host "[RUN] Skipped." -ForegroundColor DarkYellow
    Write-Host ""

    return [PSCustomObject]@{
      Run = $RunStatus
      Build = $BuildStatus
      Language = $Language
    }
  }

  $RunStatus = "Failed"

  Write-Host ""
  Write-Host "[RUN] Running $Language program..." -ForegroundColor Yellow
  Write-Host ""

  try {
    $Output = & $Executable

    if ($LASTEXITCODE -ne 0) {
      throw "Program exited with code $LASTEXITCODE."
    }

    $Output.Trim() | Write-Host
    $ActualOutput = ($Output | Out-String).Trim()

    if ($ActualOutput -ne $ExpectedOutput) {
      throw "Expected '$ExpectedOutput' but received '$ActualOutput'."
    }

    $RunStatus = "Success"

    Write-Host ""
    Write-Host "[RUN] Success." -ForegroundColor Green
  } catch {
    Write-Host ""
    Write-Host "[RUN] Failed." -ForegroundColor Red
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
  }

  Write-Host ""

  return [PSCustomObject]@{
    Run = $RunStatus
    Build = $BuildStatus
    Language = $Language
  }
}

# ------------------------------------------------------------------------------
# CMake: Execute CMake projects.
# ------------------------------------------------------------------------------

$Results += Invoke-CMakeProject -Language "C"   -Directory "c"
$Results += Invoke-CMakeProject -Language "C++" -Directory "cpp"

# ------------------------------------------------------------------------------
# .NET: Execute .NET projects.
# ------------------------------------------------------------------------------

$Results += Invoke-DotNetProject `
  -Language "C#" `
  -Directory "csharp" `
  -ProjectFile "csharp-hello-world.csproj"

# ------------------------------------------------------------------------------
# GFortran: Execute Fortran projects.
# ------------------------------------------------------------------------------

$Results += Invoke-FortranProject `
  -Language "Fortran" `
  -Directory "fortran" `
  -SourceFile "src/main.f90"

# ------------------------------------------------------------------------------
# SUMMARY: DISPLAY RESULTS.
# ------------------------------------------------------------------------------

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$Results | Format-Table Language, Build, Run -AutoSize

$Total = $Results.Count
$Successful = @(
  $Results | Where-Object {
    $_.Build -eq "Success" -and $_.Run -eq "Success"
  }
).Count

Write-Host "Successful: $Successful / $Total" -ForegroundColor Green

# ------------------------------------------------------------------------------
# EXIT: RETURN RESULTS.
# ------------------------------------------------------------------------------

$Failed = $Total - $Successful

if ($Failed -gt 0) {
  Write-Host "Overall: Failed ($Failed project(s) unsuccessful)." -ForegroundColor Red
  exit 1
}

Write-Host "Overall: Success." -ForegroundColor Green
exit 0
