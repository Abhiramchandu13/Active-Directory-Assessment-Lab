<#
.SYNOPSIS
    Installs Active Directory Domain Services and creates a new forest.

.DESCRIPTION
    A simple, beginner-friendly script to install the Active Directory
    Domain Services and DNS Server roles on Windows Server, and promote
    the server to a Domain Controller for cyberlab.local.
#>

# Stop if a command fails, rather than continuing with an incomplete setup.
$ErrorActionPreference = "Stop"

# Step 1: Install Active Directory Domain Services and DNS Server roles
# Install-WindowsFeature installs server roles and features.
# -IncludeManagementTools installs RSAT and the Active Directory PowerShell module.
Write-Host "Installing Active Directory Domain Services and DNS..." -ForegroundColor Cyan
$Result = Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools
if (-not $Result.Success) {
    throw "Role installation failed. Fix the reported error before continuing."
}

# Step 2: Prompt for Directory Services Restore Mode (DSRM) password securely
# Read-Host with -AsSecureString prompts for a password and hides keystrokes.
Write-Host "Please enter the DSRM (Directory Services Restore Mode) password:" -ForegroundColor Yellow
$DSRMPassword = Read-Host -Prompt "Enter DSRM Password" -AsSecureString

# Step 3: Install the new Active Directory Forest
# Install-ADDSForest promotes this server to a Domain Controller and sets up the cyberlab.local forest.
# The server will automatically restart upon completion.
Write-Host "Installing Active Directory Forest (cyberlab.local)..." -ForegroundColor Cyan
Install-ADDSForest `
    -DomainName "cyberlab.local" `
    -DomainNetbiosName "CYBERLAB" `
    -SafeModeAdministratorPassword $DSRMPassword `
    -InstallDns:$true `
    -Force:$true
