<#
.SYNOPSIS
    Creates and configures basic SMB file shares for the Active Directory lab.

.DESCRIPTION
    This script creates share folders under C:\LabShares, sets up SMB file shares
    using New-SmbShare, and assigns share permissions to Active Directory groups
    using Grant-SmbShareAccess, plus matching NTFS folder permissions.

    Shares created:
    - IT:          IT-Admins, IT-Support, Domain Admins
    - HR:          HR-Team, Domain Admins
    - Developers:  Developers, Domain Admins
    - Management:  Management, Domain Admins
    - Public:      Domain Users, Domain Admins
#>

param (
    [string]$Domain = "CYBERLAB",
    [string]$ShareRoot = "C:\LabShares"
)

$ErrorActionPreference = "Stop"

# Define the shares and groups with their access levels
$ShareList = @(
    @{
        Name        = "IT"
        Path        = "$ShareRoot\IT"
        Description = "IT Department Share"
        Permissions = @(
            @{ Group = "$Domain\Domain Admins"; Access = "Full" },
            @{ Group = "$Domain\IT-Admins";     Access = "Full" },
            @{ Group = "$Domain\IT-Support";    Access = "Change" }
        )
    },
    @{
        Name        = "HR"
        Path        = "$ShareRoot\HR"
        Description = "Human Resources Share"
        Permissions = @(
            @{ Group = "$Domain\Domain Admins"; Access = "Full" },
            @{ Group = "$Domain\HR-Team";       Access = "Change" }
        )
    },
    @{
        Name        = "Developers"
        Path        = "$ShareRoot\Developers"
        Description = "Software Developers Share"
        Permissions = @(
            @{ Group = "$Domain\Domain Admins"; Access = "Full" },
            @{ Group = "$Domain\Developers";    Access = "Change" }
        )
    },
    @{
        Name        = "Management"
        Path        = "$ShareRoot\Management"
        Description = "Management Share"
        Permissions = @(
            @{ Group = "$Domain\Domain Admins"; Access = "Full" },
            @{ Group = "$Domain\Management";    Access = "Change" }
        )
    },
    @{
        Name        = "Public"
        Path        = "$ShareRoot\Public"
        Description = "Company Public Share"
        Permissions = @(
            @{ Group = "$Domain\Domain Admins"; Access = "Full" },
            @{ Group = "$Domain\Domain Users";  Access = "Read" }
        )
    }
)

# Use a dedicated lab folder. This script replaces its department-folder permissions.
$ShareRoot = [System.IO.Path]::GetFullPath($ShareRoot)
if ($ShareRoot.TrimEnd('\') -eq [System.IO.Path]::GetPathRoot($ShareRoot).TrimEnd('\')) {
    throw "Choose a dedicated folder such as C:\LabShares, not a drive root."
}

# Validate every existing share before changing any folders or permissions.
$ExistingShares = @(Get-SmbShare)
foreach ($Share in $ShareList) {
    $Share.Path = Join-Path $ShareRoot $Share.Name
    $ExistingShare = $ExistingShares | Where-Object Name -eq $Share.Name
    if (@($ExistingShare).Count -gt 1) {
        throw "Multiple shares named $($Share.Name) exist. Use a simple, standalone lab server."
    }
    if ($ExistingShare -and $ExistingShare.Path.TrimEnd('\') -ine $Share.Path.TrimEnd('\')) {
        throw "Share '$($Share.Name)' already points to '$($ExistingShare.Path)'. Expected '$($Share.Path)'. No permissions were changed."
    }

    # Reject links/junctions in the path: they can point outside the lab folder.
    $PathToCheck = $Share.Path
    while ($PathToCheck) {
        if (Test-Path -LiteralPath $PathToCheck) {
            $Item = Get-Item -LiteralPath $PathToCheck -Force
            if (-not $Item.PSIsContainer -or ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                throw "Use ordinary directories, not files or junctions: $PathToCheck"
            }
        }
        $PathToCheck = Split-Path -Path $PathToCheck -Parent
    }

    # Resolve groups now, so missing groups fail before permission changes begin.
    foreach ($Perm in $Share.Permissions) {
        $Account = New-Object System.Security.Principal.NTAccount($Perm.Group)
        $Perm.Sid = $Account.Translate([System.Security.Principal.SecurityIdentifier])
    }
}

foreach ($Share in $ShareList) {
    if (-not (Test-Path -LiteralPath $Share.Path)) {
        New-Item -Path $Share.Path -ItemType Directory -Force | Out-Null
    }

    # NTFS permissions control access to the files themselves.
    # Disable inherited permissions and remove old explicit rules on this folder.
    # Keep the existing owner; grant SYSTEM and local Administrators Full Control.
    $Acl = Get-Acl -LiteralPath $Share.Path
    $Acl.SetAccessRuleProtection($true, $false)
    foreach ($Rule in @($Acl.Access)) {
        $Acl.RemoveAccessRuleSpecific($Rule)
    }
    foreach ($SidText in @("S-1-5-18", "S-1-5-32-544")) {
        $Sid = New-Object System.Security.Principal.SecurityIdentifier($SidText)
        $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $Sid, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
        $Acl.AddAccessRule($Rule)
    }
    foreach ($Perm in $Share.Permissions) {
        # SMB and NTFS use different names for similar permission levels.
        $Rights = switch ($Perm.Access) {
            "Full"   { "FullControl" }
            "Change" { "Modify" }
            "Read"   { "ReadAndExecute" }
        }
        $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $Perm.Sid, $Rights, "ContainerInherit, ObjectInherit", "None", "Allow")
        $Acl.AddAccessRule($Rule)
    }
    Set-Acl -LiteralPath $Share.Path -AclObject $Acl

    # SMB permissions control access through the network share.
    $ExistingShare = $ExistingShares | Where-Object Name -eq $Share.Name
    if (-not $ExistingShare) {
        New-SmbShare -Name $Share.Name -Path $Share.Path -Description $Share.Description -FullAccess "$Domain\Domain Admins" | Out-Null
    }

    # Replace old share permissions, including unwanted Allow and Deny entries.
    foreach ($Entry in @(Get-SmbShareAccess -Name $Share.Name)) {
        if ($Entry.AccessControlType -eq "Deny") {
            Unblock-SmbShareAccess -Name $Share.Name -AccountName $Entry.AccountName -Force | Out-Null
        } else {
            Revoke-SmbShareAccess -Name $Share.Name -AccountName $Entry.AccountName -Force | Out-Null
        }
    }
    foreach ($Perm in $Share.Permissions) {
        Grant-SmbShareAccess -Name $Share.Name -AccountName $Perm.Group -AccessRight $Perm.Access -Force | Out-Null
    }
    Write-Host "Configured SMB and NTFS permissions: $($Share.Name)" -ForegroundColor Green
}

Write-Host "Lab share setup completed." -ForegroundColor Green
Get-SmbShare -Name "IT", "HR", "Developers", "Management", "Public" | Format-Table Name, Path, Description -AutoSize
