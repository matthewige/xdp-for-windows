<#

.SYNOPSIS
This helps start and stop ETW logging.

.PARAMETER Config
    Specifies the build configuration to use.

.PARAMETER Arch
    The CPU architecture to use.

.PARAMETER Start
    Starts the logging.

.PARAMETER Stop
    Stops the logging and converts the ETL.

.PARAMETER Name
    The name of the tracing instance and output file.

#>

param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("Debug", "Release")]
    [string]$Config = "Debug",

    [Parameter(Mandatory = $false)]
    [ValidateSet("x86", "x64", "arm", "arm64")]
    [string]$Arch = "x64",

    [Parameter(Mandatory = $false)]
    [switch]$Start = $false,

    [Parameter(Mandatory = $false)]
    [switch]$Stop = $false,

    [Parameter(Mandatory = $false)]
    [switch]$NoTextConversion = $false,

    [Parameter(Mandatory = $false)]
    [string]$Profile = $null,

    [Parameter(Mandatory = $false)]
    [string]$Name = "xdp"
)

Set-StrictMode -Version 'Latest'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

if ($Profile -eq $null -and $Start) {
    Write-Error "-Start requires -Profile"
}

# Important paths.
$RootDir = Split-Path $PSScriptRoot -Parent
$ArtifactsDir = "$RootDir\artifacts\bin\$($Arch)_$($Config)"
$TracePdb = "$RootDir\artifacts\corenet-ci-main\vm-setup\tracepdb.exe"
$WprpFile = "$RootDir\tools\xdptrace.wprp"
$TmfPath = "$ArtifactsDir\tmfs"
$LogsDir = "$RootDir\artifacts\logs"
$EtlPath = "$LogsDir\$Name.etl"
$LogPath = "$LogsDir\$Name.log"

function Start-Logging {
    Write-Host "+++++++ Starting logs +++++++"

    if (!(Test-Path $WprpFile)) {
        Write-Error "$WprpFile does not exist!"
    }

    Write-Verbose "wpr.exe -start $($WprpFile)!$($Profile) -filemode -instancename $Name"
    cmd /c "wpr.exe -start `"$($WprpFile)!$($Profile)`" -filemode -instancename $Name 2>&1"
    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.setvariable variable=NeedsReboot]true"
        Write-Error "wpr.exe failed: $LastExitCode"
    }
}

function Stop-Logging {
    New-Item -ItemType Directory -Force -Path $LogsDir | Out-Null

    Write-Host "------- Stopping logs -------"
    cmd /c "wpr.exe -stop $EtlPath -instancename $Name 2>&1"
    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.setvariable variable=NeedsReboot]true"
        Write-Error "wpr.exe failed: $LastExitCode"
    }

    if (!$NoTextConversion) {
        & $TracePdb -f "$ArtifactsDir\*.pdb" -p $TmfPath
        Invoke-Expression "netsh trace convert $($EtlPath) output=$($LogPath) tmfpath=$TmfPath overwrite=yes report=no"
    }

    # Enumerate log file sizes.
    Get-ChildItem $LogsDir | Write-Verbose
}

if ($Start) {
    Start-Logging
}

if ($Stop) {
    Stop-Logging
}
