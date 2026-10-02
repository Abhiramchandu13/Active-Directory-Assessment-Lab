<#
.SYNOPSIS
    Creates Organizational Units (OUs) in Active Directory for cyberlab.local.

.DESCRIPTION
    A simple, beginner-friendly script that sets up the Active Directory
    OU hierarchy for the CyberLab environment.

    OU Structure:
    cyberlab.local
    ├── CyberLab-Users
    │   ├── IT
    │   ├── HR
    │   ├── Developers
    │   ├── Management
    │   └── Interns
    ├── CyberLab-Computers
    │   ├── Workstations
    │   └── Servers
    ├── CyberLab-Groups
    └── CyberLab-ServiceAccounts

.NOTES
    Script Name : 02-Create-OUs.ps1
    Domain      : cyberlab.local
    Level       : Entry / Beginner
#>

# Import the Active Directory module to enable AD cmdlets
$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

# Define the root domain Distinguished Name (DN)
$DomainDN = "DC=cyberlab,DC=local"

# Define parent paths for child OUs
$UsersOU     = "OU=CyberLab-Users,$DomainDN"
$ComputersOU = "OU=CyberLab-Computers,$DomainDN"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Creating Active Directory OUs" -ForegroundColor Cyan
Write-Host " Domain: cyberlab.local" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ==============================================================================
# 1. Parent (Top-Level) Organizational Units
# ==============================================================================

# CyberLab-Users
try {
    Get-ADOrganizationalUnit -Identity "OU=CyberLab-Users,$DomainDN" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: CyberLab-Users" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "CyberLab-Users" -Path $DomainDN
    Write-Host "[CREATED] OU: CyberLab-Users" -ForegroundColor Green
}

# CyberLab-Computers
try {
    Get-ADOrganizationalUnit -Identity "OU=CyberLab-Computers,$DomainDN" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: CyberLab-Computers" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "CyberLab-Computers" -Path $DomainDN
    Write-Host "[CREATED] OU: CyberLab-Computers" -ForegroundColor Green
}

# CyberLab-Groups
try {
    Get-ADOrganizationalUnit -Identity "OU=CyberLab-Groups,$DomainDN" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: CyberLab-Groups" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "CyberLab-Groups" -Path $DomainDN
    Write-Host "[CREATED] OU: CyberLab-Groups" -ForegroundColor Green
}

# CyberLab-ServiceAccounts
try {
    Get-ADOrganizationalUnit -Identity "OU=CyberLab-ServiceAccounts,$DomainDN" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: CyberLab-ServiceAccounts" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "CyberLab-ServiceAccounts" -Path $DomainDN
    Write-Host "[CREATED] OU: CyberLab-ServiceAccounts" -ForegroundColor Green
}

# ==============================================================================
# 2. Child OUs under CyberLab-Users
# ==============================================================================

# IT
try {
    Get-ADOrganizationalUnit -Identity "OU=IT,$UsersOU" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: IT (under CyberLab-Users)" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "IT" -Path $UsersOU
    Write-Host "[CREATED] OU: IT (under CyberLab-Users)" -ForegroundColor Green
}

# HR
try {
    Get-ADOrganizationalUnit -Identity "OU=HR,$UsersOU" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: HR (under CyberLab-Users)" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "HR" -Path $UsersOU
    Write-Host "[CREATED] OU: HR (under CyberLab-Users)" -ForegroundColor Green
}

# Developers
try {
    Get-ADOrganizationalUnit -Identity "OU=Developers,$UsersOU" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: Developers (under CyberLab-Users)" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "Developers" -Path $UsersOU
    Write-Host "[CREATED] OU: Developers (under CyberLab-Users)" -ForegroundColor Green
}

# Management
try {
    Get-ADOrganizationalUnit -Identity "OU=Management,$UsersOU" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: Management (under CyberLab-Users)" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "Management" -Path $UsersOU
    Write-Host "[CREATED] OU: Management (under CyberLab-Users)" -ForegroundColor Green
}

# Interns
try {
    Get-ADOrganizationalUnit -Identity "OU=Interns,$UsersOU" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: Interns (under CyberLab-Users)" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "Interns" -Path $UsersOU
    Write-Host "[CREATED] OU: Interns (under CyberLab-Users)" -ForegroundColor Green
}

# ==============================================================================
# 3. Child OUs under CyberLab-Computers
# ==============================================================================

# Workstations
try {
    Get-ADOrganizationalUnit -Identity "OU=Workstations,$ComputersOU" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: Workstations (under CyberLab-Computers)" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "Workstations" -Path $ComputersOU
    Write-Host "[CREATED] OU: Workstations (under CyberLab-Computers)" -ForegroundColor Green
}

# Servers
try {
    Get-ADOrganizationalUnit -Identity "OU=Servers,$ComputersOU" -ErrorAction Stop
    Write-Host "[EXISTS]  OU: Servers (under CyberLab-Computers)" -ForegroundColor Yellow
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "Servers" -Path $ComputersOU
    Write-Host "[CREATED] OU: Servers (under CyberLab-Computers)" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " OU creation process completed!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

