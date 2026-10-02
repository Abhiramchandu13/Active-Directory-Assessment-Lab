<#
.SYNOPSIS
    Creates two GPOs for manual lab exercises and sets basic domain password rules.
.DESCRIPTION
    The GPOs start empty. Configure their settings yourself in gpmc.msc.
    Password rules are set directly in AD, not in a separate password GPO.
#>

$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
Import-Module GroupPolicy

$DomainName = "cyberlab.local"
$DomainDN = "DC=cyberlab,DC=local"
$WorkstationsOU = "OU=Workstations,OU=CyberLab-Computers,$DomainDN"

# Set the default domain password rules. These do not create GPO settings.
Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN -MinPasswordLength 10 -ComplexityEnabled $true
Write-Host "Domain password rules set: minimum 10 characters, complexity enabled." -ForegroundColor Green

$Policies = @(
    @{ Name = "CyberLab-Security-Baseline"; Target = $DomainDN }
    @{ Name = "CyberLab-Workstation-Policy"; Target = $WorkstationsOU }
)

# Listing GPOs first lets real connection or permission errors stop the script.
$ExistingGPOs = @(Get-GPO -All -Domain $DomainName)
foreach ($Policy in $Policies) {
    $Gpo = $ExistingGPOs | Where-Object DisplayName -eq $Policy.Name
    if (@($Gpo).Count -gt 1) {
        throw "More than one GPO is named $($Policy.Name). Resolve the duplicate names first."
    }
    if (-not $Gpo) {
        $Gpo = New-GPO -Name $Policy.Name -Domain $DomainName
        Write-Host "Created empty GPO: $($Policy.Name)" -ForegroundColor Green
    }

    # Check direct links so rerunning does not attempt to create duplicate links.
    $Links = (Get-GPInheritance -Target $Policy.Target -Domain $DomainName).GpoLinks
    if ($Links | Where-Object GpoId -eq $Gpo.Id) {
        Set-GPLink -Guid $Gpo.Id -Target $Policy.Target -Domain $DomainName -LinkEnabled Yes | Out-Null
    } else {
        New-GPLink -Guid $Gpo.Id -Target $Policy.Target -Domain $DomainName -Order 1 -LinkEnabled Yes | Out-Null
    }
    Write-Host "Linked and enabled $($Policy.Name) at $($Policy.Target)." -ForegroundColor Green
}

Write-Host "GPO setup completed. The scripts do not configure a security baseline or audit logging." -ForegroundColor Cyan
Write-Host "Exercise: edit CyberLab-Security-Baseline in gpmc.msc and configure screen saver settings."
Write-Host "Exercise: edit CyberLab-Workstation-Policy and configure Windows Firewall settings."
Write-Host "Move your joined client computer into the Workstations OU to receive its policy."
