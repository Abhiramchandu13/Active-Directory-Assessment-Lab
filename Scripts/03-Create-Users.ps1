<#
.SYNOPSIS
    Creates basic Active Directory lab users.

.DESCRIPTION
    A simple, entry-level script to create 6 test user accounts in the cyberlab.local
    domain under their respective departmental Organizational Units (OUs).
#>

# Import the Active Directory module
$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

# Set a secure default password for all new lab accounts
$Password = Read-Host "Enter temporary password" -AsSecureString

# Define the 6 lab users
$Users = @(
    @{ FirstName = "John";   LastName = "Doe";    Username = "jdoe";    OU = "IT" }
    @{ FirstName = "Alice";  LastName = "Smith";  Username = "asmith";  OU = "HR" }
    @{ FirstName = "Robert"; LastName = "Brown";  Username = "rbrown";  OU = "Developers" }
    @{ FirstName = "Sarah";  LastName = "Wilson"; Username = "swilson"; OU = "Management" }
    @{ FirstName = "David";  LastName = "Miller"; Username = "dmiller"; OU = "Developers" }
    @{ FirstName = "Emily";  LastName = "Davis";  Username = "edavis";  OU = "Interns" }
)

Write-Host "Creating Active Directory lab users..." -ForegroundColor Cyan

# Loop through each user and create the account
foreach ($User in $Users) {
    # Skip existing accounts. Do not reset their passwords when rerunning the script.
    if (Get-ADUser -Filter "SamAccountName -eq '$($User.Username)'") {
        Write-Host "User $($User.Username) already exists (Skipping)." -ForegroundColor Yellow
        continue
    }
    Write-Host "Creating user: $($User.Username) ($($User.OU))..."

    New-ADUser -Name "$($User.FirstName) $($User.LastName)" `
               -GivenName $User.FirstName `
               -Surname $User.LastName `
               -SamAccountName $User.Username `
               -UserPrincipalName "$($User.Username)@cyberlab.local" `
               -Path "OU=$($User.OU),OU=CyberLab-Users,DC=cyberlab,DC=local" `
               -AccountPassword $Password `
               -Enabled $true `
               -ChangePasswordAtLogon $true

    Write-Host "User $($User.Username) created successfully." -ForegroundColor Green
}

Write-Host "`nUser setup completed. Existing accounts were left unchanged." -ForegroundColor Cyan
