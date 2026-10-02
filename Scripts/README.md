# Active Directory Lab Setup — Beginner Edition

Seven small PowerShell scripts for an isolated Windows Server practice lab. They install AD, create OUs, users and groups, prepare GPO exercises, configure departmental shares, and produce a basic audit report.

## Requirements

- A fresh Windows Server 2019 or 2022 VM on an isolated or host-only network.
- A static server IP, for example `192.168.100.10/24`.
- Windows PowerShell opened **as Administrator**.
- A snapshot before installing AD, so you can rebuild the lab if needed.
- For client exercises, a Windows edition that supports joining an AD domain, with its DNS server set to the domain controller's IP address.

These scripts use the fixed domain `cyberlab.local` and NetBIOS name `CYBERLAB`. Run them on the lab domain controller. They are learning scripts, not a production deployment system.

## What each script does

| Script | Result |
| --- | --- |
| `01-Install-ADDS.ps1` | Installs AD DS and DNS, creates the forest, and automatically restarts the server. Run once on a fresh server. |
| `02-Create-OUs.ps1` | Creates the OU structure below. Skips existing OUs; connection and permission errors stop the script. |
| `03-Create-Users.ps1` | Creates six users with names, usernames and departmental OU placement. Prompts for a shared temporary lab password and requires a change at first login. Existing users are skipped without changing their passwords. |
| `04-Create-Groups.ps1` | Creates seven global security groups and adds the listed memberships. Skips existing groups and memberships. |
| `05-Configure-GPOs.ps1` | Sets the default domain password minimum to 10 characters with complexity enabled. Creates and links two initially empty GPOs for manual exercises. |
| `06-Configure-Shares.ps1` | Creates five SMB shares with matching NTFS folder permissions. Checks existing share paths before making changes. |
| `07-AD-Security-Audit.ps1` | Reports direct and nested Domain Admins members, enabled users with non-expiring passwords, and disabled users. Does not modify AD. |

Scripts stop when an operation fails, rather than printing a final success message for an incomplete run. Earlier successful changes remain; there is no automatic rollback. The audit records individual failed checks and continues the other checks, then reports failure if any check failed.

## Domain structure

```text
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
```

| Username | Name | OU | Added group memberships |
| --- | --- | --- | --- |
| jdoe | John Doe | IT | IT-Admins, IT-Support, Security-Team |
| asmith | Alice Smith | HR | HR-Team |
| rbrown | Robert Brown | Developers | Developers, Security-Team |
| swilson | Sarah Wilson | Management | Management |
| dmiller | David Miller | Developers | Developers |
| edavis | Emily Davis | Interns | Interns |

The script does not populate job titles or the AD Department attribute. `IT-Admins` is a custom group: its name does not grant Domain Admin privileges.

## Run the scripts

1. Open **Windows PowerShell as Administrator** as the local Administrator.
2. Navigate to wherever you copied this folder. The example below uses `F:\Active-Directory-Lab\Scripts`.
3. Allow scripts for this PowerShell session and install AD:

```powershell
cd F:\Active-Directory-Lab\Scripts
Set-ExecutionPolicy Bypass -Scope Process -Force
.\01-Install-ADDS.ps1
```

Enter a unique DSRM recovery password when prompted and keep it securely. **The server restarts automatically.** Do not rerun script 01 on the promoted server.

After reboot, sign in as `CYBERLAB\Administrator`, open Windows PowerShell as Administrator again, and run the following commands **one at a time**. Resolve any error before running the next script.

```powershell
cd F:\Active-Directory-Lab\Scripts
Set-ExecutionPolicy Bypass -Scope Process -Force
.\02-Create-OUs.ps1
.\03-Create-Users.ps1
.\04-Create-Groups.ps1
.\05-Configure-GPOs.ps1
.\06-Configure-Shares.ps1
.\07-AD-Security-Audit.ps1
```

For the temporary user password, choose at least 10 characters and meet domain complexity requirements. A shared temporary password is a lab convenience; every user must change it on first login. Setting a stronger domain policy later does not automatically replace existing passwords.

## Group Policy exercises

Script 05 creates or reuses these GPOs and enables their links:

| GPO | Linked location | Manual exercise |
| --- | --- | --- |
| CyberLab-Security-Baseline | Domain root | Configure screen saver timeout and password protection. |
| CyberLab-Workstation-Policy | Workstations OU only | Configure Windows Firewall settings. |

Open `gpmc.msc` and edit the GPOs to perform the exercises. **Creating an empty GPO does not configure a security baseline, firewall, or audit logging.** Existing GPO settings are preserved on reruns.

The password settings are written directly with `Set-ADDefaultDomainPasswordPolicy`, not stored inside a `CyberLab-Password-Policy` GPO. If an earlier script version created that empty GPO, this version leaves it untouched. Password settings in a domain-linked GPO can overwrite direct AD settings when policy is applied; keep any password settings you configure in GPMC consistent and verify the effective policy afterward.

Join a client to the domain, then use `dsa.msc` to move its computer object into `CyberLab-Computers > Workstations`. Creating the OU does not move existing computers or automatically place newly joined computers there. The Servers OU does not receive the workstation link.

## File shares and permissions

By default, script 06 uses `C:\LabShares` on the machine running it. Use this dedicated folder only for lab data.

| Share | Department access over SMB | Corresponding NTFS access |
| --- | --- | --- |
| IT | IT-Admins: Full; IT-Support: Change | Full Control; Modify |
| HR | HR-Team: Change | Modify |
| Developers | Developers: Change | Modify |
| Management | Management: Change | Modify |
| Public | Domain Users: Read | Read and Execute |

Domain Admins receive Full access to every share and Full Control on each department folder. SYSTEM and the local Administrators group also retain Full Control through explicit NTFS rules. File access must be permitted by both SMB and NTFS permissions.

**On every run**, the script replaces the SMB permissions and the NTFS permissions on the five department folders with the rules above. It disables inheritance from their parent folder and replaces old explicit rules on those five folders. Do not point it at existing business shares or folders with permissions you need to preserve.

New files and subfolders inherit the folder rules. The script does not recursively reset custom explicit permissions or disabled inheritance on existing child items; use new, empty lab folders for predictable results. It does not change file ownership.

If a share name already points to a different folder, the script stops before changing permissions. It also rejects junctions and symbolic links in the configured folder paths. Changes are not transactional: a later failure can leave partially configured permissions. Correct the error and rerun the script.

Optional custom lab location:

```powershell
.\06-Configure-Shares.ps1 -ShareRoot 'C:\MyLabShares'
```

Use the same location on subsequent runs. Changing the parameter does not move an existing share.

## Verify the lab

- Open `dsa.msc` to inspect OUs, accounts, and memberships.
- Open `gpmc.msc` to inspect both GPO links and the settings you configured manually.
- Check the effective default password rules:

```powershell
Get-ADDefaultDomainPasswordPolicy -Identity cyberlab.local |
    Select-Object MinPasswordLength, ComplexityEnabled
```

- On the client, run `gpupdate /force`, then inspect applied computer policies with `gpresult /r /scope computer` from an elevated prompt.
- Use the actual server name for shares, for example `\\LAB-DC01\Public` (replace `LAB-DC01` with your server name).
- Test as ordinary lab users: HR users should create and edit files in HR; an unrelated user should be denied; ordinary users should read Public but not create files there. Sign out and back in after group membership changes. Testing only as Domain Administrator does not verify department restrictions.
- Inspect both permission layers on the server:

```powershell
Get-SmbShareAccess -Name HR
(Get-Acl -LiteralPath C:\LabShares\HR).Access
```

The audit report defaults to `AD-Security-Audit.txt` in the current user's profile folder. Each run overwrites the previous report. Choose another existing output directory if needed:

```powershell
.\07-AD-Security-Audit.ps1 -OutputFile 'C:\LabShares\audit.txt'
```

The audit is a basic inventory, not a full security assessment. Disabled accounts are not automatically vulnerabilities. A `FAILED` section means that check did not complete; it does not mean no matching accounts exist.

## Reruns and troubleshooting

- Scripts 02–04 skip existing objects; they do not move users, repair existing group types, or remove extra memberships.
- Script 05 reapplies the two password values and ensures the GPO links are enabled. Other password settings remain unchanged.
- Script 06 reapplies its defined permissions; review the permission behavior above before rerunning.
- If a module is missing, verify AD DS management tools and Group Policy Management are installed. Use Windows PowerShell on the lab server.
- For access errors, confirm the shell is elevated and you are signed in as `CYBERLAB\Administrator`.
- If the client cannot find the domain, set its DNS server to the domain controller's IP, not `127.0.0.1` or a public DNS resolver.
- If a command fails, read the error, correct the cause, and rerun that script before continuing. A successful syntax check alone does not verify a working AD deployment.
