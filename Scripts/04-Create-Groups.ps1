<#
.SYNOPSIS
    Creates Active Directory security groups and assigns users to them.

.DESCRIPTION
    A beginner-friendly PowerShell script to create basic security groups
    in Active Directory and add user accounts into their respective groups.
    It includes simple checks to safely skip groups and users if they already exist.
#>

# Import the Active Directory module
$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

# Define the OU path where the groups will be stored
$GroupPath = "OU=CyberLab-Groups,DC=cyberlab,DC=local"

Write-Host "Creating Active Directory Security Groups..." -ForegroundColor Cyan

# Define our groups in a simple array
$GroupsToCreate = @(
    @{ Name = "IT-Admins";     Description = "IT Administrators" }
    @{ Name = "IT-Support";    Description = "IT Support Staff" }
    @{ Name = "HR-Team";       Description = "Human Resources Team" }
    @{ Name = "Developers";    Description = "Software Developers" }
    @{ Name = "Management";    Description = "Management Team" }
    @{ Name = "Interns";       Description = "Interns" }
    @{ Name = "Security-Team"; Description = "Security Team" }
)

# Loop through and create each group if it doesn't already exist
foreach ($Group in $GroupsToCreate) {
    if (-not (Get-ADGroup -Filter "SamAccountName -eq '$($Group.Name)'")) {
        New-ADGroup -Name $Group.Name -SamAccountName $Group.Name -GroupScope Global -GroupCategory Security -Path $GroupPath -Description $Group.Description
        Write-Host "Created group: $($Group.Name)" -ForegroundColor Green
    } else {
        Write-Host "Group already exists (Skipping): $($Group.Name)" -ForegroundColor Yellow
    }
}

# ----------------------------------------------------
# 2. Add Users to Groups
# ----------------------------------------------------
Write-Host "`nAdding users to groups..." -ForegroundColor Cyan

# Define our memberships in a simple array
$Memberships = @(
    @{ Group = "IT-Admins";     User = "jdoe" }
    @{ Group = "IT-Support";    User = "jdoe" }
    @{ Group = "HR-Team";       User = "asmith" }
    @{ Group = "Developers";    User = "rbrown" }
    @{ Group = "Developers";    User = "dmiller" }
    @{ Group = "Management";    User = "swilson" }
    @{ Group = "Interns";       User = "edavis" }
    @{ Group = "Security-Team"; User = "jdoe" }
    @{ Group = "Security-Team"; User = "rbrown" }
)

# Loop through and add users if they aren't already in the group
foreach ($Membership in $Memberships) {
    # Check if user is already a member
    $currentMembers = Get-ADGroupMember -Identity $Membership.Group | Select-Object -ExpandProperty SamAccountName
    
    if ($currentMembers -notcontains $Membership.User) {
        Add-ADGroupMember -Identity $Membership.Group -Members $Membership.User
        Write-Host "Added $($Membership.User) to $($Membership.Group)" -ForegroundColor Green
    } else {
        Write-Host "User $($Membership.User) is already in $($Membership.Group) (Skipping)" -ForegroundColor Yellow
    }
}

# ----------------------------------------------------
# 3. Verify Group Members
# ----------------------------------------------------
Write-Host "`nGroup Provisioning Complete! Here is a summary of memberships:" -ForegroundColor Cyan

foreach ($Group in $GroupsToCreate) {
    Write-Host "`n[$($Group.Name)] Members:" -ForegroundColor White
    $members = Get-ADGroupMember -Identity $Group.Name
    if ($members) {
        $members | ForEach-Object { Write-Host " - $($_.SamAccountName)" -ForegroundColor Gray }
    } else {
        Write-Host " - (Empty)" -ForegroundColor DarkGray
    }
}
