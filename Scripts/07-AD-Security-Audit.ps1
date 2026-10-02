<#
.SYNOPSIS
    Reports direct and nested Domain Admins, non-expiring passwords, and disabled users.
.DESCRIPTION
    Reads AD without changing it. Overwrites the selected report file on each run.
    A failed query is recorded as FAILED, not mistaken for an empty result.
#>
param (
    [string]$OutputFile = "$env:USERPROFILE\AD-Security-Audit.txt"
)

$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

"ACTIVE DIRECTORY SECURITY AUDIT" | Out-File -FilePath $OutputFile
"Date: $(Get-Date)" | Out-File -FilePath $OutputFile -Append
"Computer: $env:COMPUTERNAME" | Out-File -FilePath $OutputFile -Append

# Each check is a small block of PowerShell that runs inside the loop below.
$Checks = @(
    @{ Name = "Direct Domain Admins members"; Query = {
        Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name, SamAccountName, ObjectClass
    } }
    @{ Name = "Domain Admins members including nested groups"; Query = {
        Get-ADGroupMember -Identity "Domain Admins" -Recursive | Select-Object Name, SamAccountName, ObjectClass
    } }
    @{ Name = "Enabled users with non-expiring passwords"; Query = {
        Get-ADUser -Filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} -Properties PasswordNeverExpires |
            Select-Object Name, SamAccountName, Enabled
    } }
    @{ Name = "Disabled users (not necessarily a security problem)"; Query = {
        Get-ADUser -Filter {Enabled -eq $false} | Select-Object Name, SamAccountName, Enabled
    } }
)

$FailedChecks = 0
foreach ($Check in $Checks) {
    "`n--- $($Check.Name) ---" | Out-File -FilePath $OutputFile -Append
    try {
        # The & operator runs the query block stored above.
        $Results = @(& $Check.Query)
        if ($Results.Count -eq 0) {
            "No matching objects found." | Out-File -FilePath $OutputFile -Append
        } else {
            $Results | Format-Table -AutoSize | Out-String -Width 240 | Out-File -FilePath $OutputFile -Append
        }
    } catch {
        $FailedChecks++
        "FAILED: $($_.Exception.Message)" | Out-File -FilePath $OutputFile -Append
    }
}

if ($FailedChecks -gt 0) {
    throw "$FailedChecks audit check(s) failed. See $OutputFile for details."
}
Write-Host "Audit completed. Report: $OutputFile" -ForegroundColor Green
