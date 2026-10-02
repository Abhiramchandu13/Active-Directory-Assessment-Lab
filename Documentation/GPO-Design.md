# Group Policy Design

## What the script actually configures

| Item | Target | Result |
| --- | --- | --- |
| Default domain password policy | cyberlab.local | Minimum password length 10; complexity enabled, using Set-ADDefaultDomainPasswordPolicy. |
| CyberLab-Security-Baseline | DC=cyberlab,DC=local | Creates an initially empty GPO if absent and enables its domain link. |
| CyberLab-Workstation-Policy | OU=Workstations,OU=CyberLab-Computers,DC=cyberlab,DC=local | Creates an initially empty GPO if absent and enables its OU link. |

Existing GPO settings are preserved. The script fails if it finds duplicate GPO display names for either expected policy. New links are created at order 1; existing links are enabled without explicitly resetting their order.

The script does **not** configure account lockout values, drive mappings, Control Panel restrictions, service-account logon restrictions, firewall settings, screen savers, or audit logging. A GPO name and enabled link are not evidence that any settings are enforced.

## Domain password policy

The password values are written directly to AD, not into either custom GPO. Other password and lockout properties remain unchanged by this command. See [Microsoft's cmdlet reference](https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-addefaultdomainpasswordpolicy).

Keep password settings in domain-linked GPOs consistent with the intended domain policy; subsequent policy processing can change effective values. Verify the domain policy after processing. Existing passwords are not automatically replaced by setting a new minimum, and a user's fine-grained password policy, if configured separately, can differ from the default.

```powershell
Import-Module ActiveDirectory
Get-ADDefaultDomainPasswordPolicy -Identity cyberlab.local |
    Select-Object MinPasswordLength, ComplexityEnabled,
        PasswordHistoryCount, MinPasswordAge, MaxPasswordAge,
        LockoutThreshold, LockoutDuration, LockoutObservationWindow
```

Fine-grained policies are not created by these scripts. Domain password policy should not be confused with local-account password policy on member computers. See [Microsoft's password policy documentation](https://learn.microsoft.com/windows/security/threat-protection/security-policy-settings/password-policy).

## Manual lab exercises

1. Open Group Policy Management (`gpmc.msc`) on the lab server.
2. Edit CyberLab-Security-Baseline. As an exercise, configure screen saver timeout and password protection under User Configuration > Policies > Administrative Templates > Control Panel > Personalization.
3. Edit CyberLab-Workstation-Policy. As a separate exercise, configure the intended Windows Defender Firewall settings under Computer Configuration > Policies > Windows Settings > Security Settings > Windows Defender Firewall with Advanced Security.
4. Join a test client and move its computer object into CyberLab-Computers > Workstations with `dsa.msc`.
5. Verify the configured settings and effective behavior on that client.

Record chosen values and test results. Neither exercise is performed automatically. The domain link has broad scope, so review any settings added there before applying them.

## Scope and service-account restrictions

GPO links can target sites, domains or OUs. User settings normally follow users; computer settings follow computers. For example, user settings linked only to Workstations will not normally apply to users in CyberLab-Users unless additional processing such as loopback is deliberately configured. See [Microsoft's Group Policy scope documentation](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-scope).

Deny local logon and deny Remote Desktop logon are computer-side user rights. A future service-account exercise must define the appropriate denied principals and apply the settings to the computers being protected. The ServiceAccounts OU alone provides no such protection. The [Microsoft user-rights documentation](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/allow-log-on-locally) describes the computer-policy location and the relationship between allow and deny rights.

## Verification and troubleshooting

On the server, inspect links and actual settings in GPMC. On the test client:

```powershell
gpupdate /force
gpresult /r /scope user
```

Run the user-scope command as the affected user. In an elevated client prompt, inspect computer results:

```powershell
gpresult /r /scope computer
gpresult /h "$env:TEMP\CyberLab-GPResult.html" /f
```

Empty GPOs may be filtered out; their absence from applied settings is not proof of a broken link. Check the GPO's Settings tab and test a deliberately configured setting.

If results differ from expectations, check client DNS and domain connectivity, user/computer OU placement, enabled links, enabled GPO sections, security/WMI filtering, inheritance and competing settings. Sign out or restart when the setting requires it. The usual local/site/domain/OU processing order has exceptions such as enforced links and blocked inheritance; proximity alone does not determine every result.

## Future exercises

Windows LAPS, advanced auditing, local Administrators membership management, application control and service-account logon restrictions require additional configuration and testing. None is implemented by script 05.
