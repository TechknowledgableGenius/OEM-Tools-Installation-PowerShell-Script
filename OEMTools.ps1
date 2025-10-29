<#
.SYNOPSIS
  Installs vendor-specific support/update tools depending on the computer manufacturer.

.DESCRIPTION
  Detects Dell, HP, Lenovo, and installs the respective support utilities
  (e.g. Dell SupportAssist/Command Update/Digital Delivery, HP Support Assistant, Lenovo System Update).

  The script first checks for the installer executable in the same directory as the script.
  If not found, it attempts to download the installer from a predefined URL.
  It must be run as Administrator.

.NOTES
  You must ensure the correct installer URLs and silent switches are used.
  URLs provided below are examples and may change over time; always verify them.
  Requires Administrator privileges.
#>

# Get the directory the script is running from for local file checks
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

### Utility: Get manufacturer ###
function Get-ComputerManufacturer {
    try {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem
        return $cs.Manufacturer.Trim()
    }
    catch {
        Write-Error "Could not retrieve computer manufacturer: $($_.Exception.Message)"
        return ""
    }
}

### Utility: run installer with logging and local/download logic ###
function Install-IfNotPresent {
    param (
        [string] $appName,
        [string] $localFileName,
        [string] $downloadUrl,
        [string] $silentArgs = '/s /v"/qn /norestart"',
        [string] $checkPath = $null
    )

    Write-Host "--- Checking for $appName ---"

    # 1. Check for existing installation
    if ($checkPath -and (Test-Path $checkPath)) {
        Write-Host "$appName already installed at $checkPath."
        return
    }

    # 2. Determine installer location
    $localFileFullPath = Join-Path $ScriptDir $localFileName
    $installer = $null
    $isDownloaded = $false
    $tempFile = $null

    if (Test-Path $localFileFullPath) {
        $installer = $localFileFullPath
        Write-Host "Found local installer: $localFileFullPath"
    } elseif ($downloadUrl -match '^https?://') {
        $tempFile = Join-Path $env:TEMP $localFileName
        try {
            Write-Host "Installer not found locally. Downloading from $downloadUrl to $tempFile"
            Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing -TimeoutSec 300
            $installer = $tempFile
            $isDownloaded = $true
        } catch {
            Write-Warning "Failed to download ${appName} installer: $($_.Exception.Message)"
            return
        }
    } else {
        Write-Warning "No local installer found for $appName and no valid download URL provided."
        return
    }

    # 3. Run Installation
    Write-Host "Installing $appName from $installer with arguments: '$silentArgs'"
    try {
        $p = Start-Process -FilePath $installer -ArgumentList $silentArgs -Wait -PassThru -ErrorAction Stop
        if ($p.ExitCode -eq 0) {
            Write-Host "$appName installation succeeded (Exit Code: 0)."
        } else {
            Write-Warning "$appName installation returned non-zero exit code $($p.ExitCode)."
        }
    } catch {
        Write-Error "Failed to start or complete installation for ${appName}: $($_.Exception.Message)"
    }

    # 4. Clean up downloaded file
    if ($isDownloaded -and $tempFile -and (Test-Path $tempFile)) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}

### Main logic ###
function Install-VendorTools {
    $manu = Get-ComputerManufacturer
    if (-not $manu) {
        Write-Warning "Manufacturer could not be determined. Exiting."
        return
    }

    Write-Host "Detected manufacturer: '$manu'"
    $m = $manu.ToLower()

    switch -Wildcard ($m) {
        "*dell*" {
            Write-Host "--- Installing Dell tools ---"
            $dcuUrl = "https://dl.dell.com/FOLDER13309588M/2/Dell-Command-Update-Windows-Universal-Application_C8JXV_WIN64_5.5.0_A00_01.EXE"
            $dcuFile = "Dell-Command-Update.exe"
            $dcuCheck = Join-Path "${env:ProgramFiles}\Dell\CommandUpdate" "dcu-cli.exe"
            Install-IfNotPresent -appName "Dell Command Update" -localFileName $dcuFile -downloadUrl $dcuUrl -checkPath $dcuCheck -silentArgs $silentArgs

            $dsUrl = "https://dl.dell.com/FOLDER10091480M/1/Dell-SupportAssistInstaller.exe"
            $dsFile = "Dell-SupportAssistInstaller.exe"
            $dsCheck = Join-Path "${env:ProgramFiles}\Dell\SupportAssistAgent" "SupportAssist.exe"
            Install-IfNotPresent -appName "Dell SupportAssist" -localFileName $dsFile -downloadUrl $dsUrl -checkPath $dsCheck

            $dddUrl = "https://dl.dell.com/FOLDER13316209M/1/Dell-Digital-Delivery-Application_3K46D_WIN_5.0.86.0_A00.EXE"
            $dddFile = "DellDigitalDelivery.exe"
            $dddCheck = Join-Path "${env:ProgramFiles}\Dell\Digital Delivery" "DigitalDelivery.exe"
            Install-IfNotPresent -appName "Dell Digital Delivery" -localFileName $dddFile -downloadUrl $dddUrl -checkPath $dddCheck

            if (Test-Path $dcuCheck) {
                Write-Host "Running Dell Command Update scan & apply..."
                & $dcuCheck /scan
                & $dcuCheck /applyUpdates
            }
        }

        "*hp*" {
            Write-Host "--- Installing HP Support Assistant ---"
            $hpUrl = "https://ftp.hp.com/pub/softpaq/sp163001-163500/sp163238.exe"
            $hpFile = "sp163238.exe"
            $hpCheck = Join-Path "${env:ProgramFiles}\HP\HP Support Assistant" "HPLauncher.exe"
            Install-IfNotPresent -appName "HP Support Assistant" -localFileName $hpFile -downloadUrl $hpUrl -checkPath $hpCheck -silentArgs $silentArgs
        }

        "*lenovo*" {
            Write-Host "--- Installing Lenovo System Update ---"
            $lsuUrl = "https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.03.59.exe"
            $lsuFile = "SystemUpdate.exe"
            $lsuCheck = Join-Path "${env:ProgramFiles}\Lenovo\System Update" "systemupdatetool.exe"
            Install-IfNotPresent -appName "Lenovo System Update" -localFileName $lsuFile -downloadUrl $lsuUrl -checkPath $lsuCheck
        }

        Default {
            Write-Warning "Manufacturer '$manu' not recognized or not handled (only Dell, HP, Lenovo supported in this script)."
        }
    }
}

### Run Script with Elevation Check ###
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Error "This script must be run as Administrator."
} else {
    Install-VendorTools
    Write-Host "All specified OEM tool checks/installations are complete."
}
