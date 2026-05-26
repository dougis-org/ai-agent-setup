<#
.SYNOPSIS
    Installs a general-purpose agent skill from the catalog either locally to a repo or centrally for a user.
.DESCRIPTION
    Lists available skills in the catalog, lets you select one, and installs/symlinks it
    to your local agent surfaces or global configuration directories.
.PARAMETER SkillName
    The name of the skill folder to install (e.g. codebase-health).
.PARAMETER Target
    Specify 'local' (inside a repo) or 'central' (centralized user config).
.PARAMETER Path
    Custom destination path to install the skill.
.PARAMETER Copy
    If set, copy the skill files instead of creating symlinks (useful when symlinks are restricted).
.EXAMPLE
    .\install-skill.ps1 -SkillName codebase-health -Target central
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$SkillName,

    [Parameter(Mandatory=$false)]
    [ValidateSet("local", "central")]
    [string]$Target,

    [Parameter(Mandatory=$false)]
    [string]$Path,

    [Parameter(Mandatory=$false)]
    [switch]$Copy
)

# ── Helper Function (Defined First for PowerShell Scoping) ───────────────────
function Install-SkillFiles {
    param (
        [string]$Source,
        [string]$Destination,
        [bool]$CopyMode
    )
    
    # If destination already exists, remove it (re-run is idempotent)
    if (Test-Path $Destination) {
        Remove-Item -Path $Destination -Recurse -Force | Out-Null
    }
    
    # Try Symlink first unless explicitly in copy mode
    if (-not $CopyMode) {
        try {
            Write-Host "  link  $Destination  ->  $Source" -ForegroundColor Gray
            New-Item -ItemType Junction -Path $Destination -Value $Source -ErrorAction Stop | Out-Null
            return
        }
        catch {
            Write-Host "  [!] Junction creation failed (permissions/restrictions). Falling back to Copy Mode..." -ForegroundColor Yellow
            $CopyMode = $true
        }
    }
    
    if ($CopyMode) {
        Write-Host "  copy  $Destination  <-  $Source" -ForegroundColor Gray
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force | Out-Null
    }
}

# Move to the script's directory and find repository root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($ScriptDir)) {
    $ScriptDir = "."
}
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$CatalogPath = Join-Path $RepoRoot "catalog\skills"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "      AGENT SKILL INSTALLATION TOOL          " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Check catalog existence
if (-not (Test-Path $CatalogPath)) {
    Write-Error "Catalog path not found at: $CatalogPath"
    exit 1
}

# 2. Get available skills
$AvailableSkills = Get-ChildItem $CatalogPath -Directory | Select-Object -ExpandProperty Name
if ($AvailableSkills.Count -eq 0) {
    Write-Error "No skills found in catalog at: $CatalogPath"
    exit 1
}

# 3. Select Skill if not provided
if ([string]::IsNullOrEmpty($SkillName)) {
    Write-Host ""
    Write-Host "Available Skills in Catalog:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $AvailableSkills.Count; $i++) {
        Write-Host "  [$($i + 1)] $($AvailableSkills[$i])" -ForegroundColor White
    }
    
    $selection = -1
    while ($selection -lt 1 -or $selection -gt $AvailableSkills.Count) {
        Write-Host ""
        $input = Read-Host "Select a skill number (1-$($AvailableSkills.Count))"
        if ([int]::TryParse($input, [ref]$selection)) {
            if ($selection -lt 1 -or $selection -gt $AvailableSkills.Count) {
                Write-Host "Invalid selection. Please choose between 1 and $($AvailableSkills.Count)." -ForegroundColor Red
            }
        } else {
            Write-Host "Please enter a valid number." -ForegroundColor Red
            $selection = -1
        }
    }
    $SkillName = $AvailableSkills[$selection - 1]
} else {
    if ($SkillName -notin $AvailableSkills) {
        Write-Error "Skill '$SkillName' not found in catalog. Available options: $($AvailableSkills -join ', ')"
        exit 1
    }
}

# 4. Select Target if not provided
if ([string]::IsNullOrEmpty($Target)) {
    Write-Host ""
    Write-Host "Where would you like to install the skill?" -ForegroundColor Yellow
    Write-Host "  [1] Local Repository (install to current repository's .codex, .claude, .gemini, and .github surfaces)" -ForegroundColor White
    Write-Host "  [2] Central User Profile (install centrally for all projects in your user configuration)" -ForegroundColor White
    
    $targetSelection = ""
    while ($targetSelection -ne "1" -and $targetSelection -ne "2") {
        Write-Host ""
        $targetSelection = Read-Host "Select installation target (1 or 2)"
    }
    
    if ($targetSelection -eq "1") {
        $Target = "local"
    } else {
        $Target = "central"
    }
}

$SourceSkillDir = Join-Path $CatalogPath $SkillName
Write-Host ""
Write-Host "Selected Skill: " -NoNewline -ForegroundColor White
Write-Host $SkillName -ForegroundColor Green
Write-Host "Selected Target: " -NoNewline -ForegroundColor White
Write-Host $Target -ForegroundColor Green

# 5. Execute Installation
if ($Target -eq "local") {
    # Determine Local Destination
    if ([string]::IsNullOrEmpty($Path)) {
        $DestPath = (Get-Location).Path
    } else {
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }
        $DestPath = (Resolve-Path $Path).Path
    }
    
    Write-Host "Installing to local repository: $DestPath" -ForegroundColor Gray
    
    # Supported Local Agent Surfaces
    $Surfaces = @(
        ".codex\skills",
        ".claude\skills",
        ".gemini\skills",
        ".github\skills"
    )
    
    foreach ($surface in $Surfaces) {
        $SurfaceDir = Join-Path $DestPath $surface
        $SkillDestDir = Join-Path $SurfaceDir $SkillName
        
        # Create parent directory if missing
        if (-not (Test-Path $SurfaceDir)) {
            New-Item -ItemType Directory -Path $SurfaceDir -Force | Out-Null
        }
        
        Install-SkillFiles -Source $SourceSkillDir -Destination $SkillDestDir -CopyMode $Copy
    }
}
else {
    # Central/Global Installation
    $UserHome = [System.Environment]::GetFolderPath("UserProfile")
    
    $DestPaths = @()
    if ([string]::IsNullOrEmpty($Path)) {
        # Install to standard central paths:
        # Antigravity/Gemini Config
        $DestPaths += Join-Path $UserHome ".gemini\config\skills\$SkillName"
        $DestPaths += Join-Path $UserHome ".gemini\antigravity-ide\skills\$SkillName"
        # Claude Code
        $DestPaths += Join-Path $UserHome ".claude\skills\$SkillName"
        # Codex
        $DestPaths += Join-Path $UserHome ".codex\skills\$SkillName"
    } else {
        $DestPaths += Join-Path $Path $SkillName
    }
    
    foreach ($dest in $DestPaths) {
        $ParentDir = Split-Path -Parent $dest
        if (-not (Test-Path $ParentDir)) {
            New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
        }
        Install-SkillFiles -Source $SourceSkillDir -Destination $dest -CopyMode $Copy
    }
}

Write-Host ""
Write-Host "Installation Completed Successfully! [OK]" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
