<#

.SYNOPSIS
This provisions a CI agent. The 1ES managed agent pool executes this script
after starting a new agent VM and automatically reboots. The script must be
copied to the Azure storage blob used for provisioning.

#>

param (
)

Write-Host "Enable test signing"
bcdedit.exe /set testsigning on

Write-Host "Enable driver verifier"
verifier.exe /standard /driver xdp.sys xdpfnmp.sys
