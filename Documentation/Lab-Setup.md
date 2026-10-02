# Lab Setup
## Read the documentation

- [AD Design](AD-Design.md): OUs, accounts and object placement.
- [GPO Design](GPO-Design.md): the two initially empty GPOs, domain password settings and manual exercises.
- [RBAC Design](RBAC-Design.md): exact group memberships and share permissions.
- [Security Controls](Security-Controls.md): implemented behavior, audit coverage and limitations.

## Architecture and prerequisites

Use a fresh Windows Server 2019 or 2022 VM for an isolated practice domain. The server runs AD DS, DNS and the lab file shares. A separate domain-joined client is needed to test user access and workstation policies.

- Use an isolated/internal or host-only lab network. If NAT is needed for updates, keep the lab separate from production networks and do not forward inbound internet traffic to it.
- Allocate at least 4 GB RAM (8 GB recommended for this exercise) and 60 GB disk as lab planning values.
- Choose the final server hostname and a static IP before promotion.
- Take a snapshot of the fresh server before installing AD.
- Use Windows PowerShell as Administrator on the lab server. Scripts 02–05 and 07 need the ActiveDirectory module; script 05 also needs GroupPolicy/GPMC. If missing, install the appropriate Windows Server management tools before continuing.
- Use a client Windows edition that supports AD domain join, such as Windows 11 Pro or Enterprise.
- The domain is fixed as `cyberlab.local`, with NetBIOS name `CYBERLAB`. This is an isolated-lab naming choice.

The scripts do not create VMs, configure IP addresses, rename hosts, join clients or move client computer objects.

## DNS and paths

Point clients at the domain controller's static IP for DNS. Do not use public DNS as an alternate AD client resolver. Configure external name resolution through the lab DNS server if required. The installation enables DNS on the domain controller; verify its own DNS client settings and domain name resolution after promotion.

The folders currently exist separately:

```text
F:\
├── Active-Directory-Lab\
│   └── Scripts\
│       ├── 01-Install-ADDS.ps1
│       ├── 02-Create-OUs.ps1
│       ├── 03-Create-Users.ps1
│       ├── 04-Create-Groups.ps1
│       ├── 05-Configure-GPOs.ps1
│       ├── 06-Configure-Shares.ps1
│       ├── 07-AD-Security-Audit.ps1
│       └── README.md
└── Documentation\
    ├── Lab-Setup.md
    ├── AD-Design.md
    ├── GPO-Design.md
    ├── RBAC-Design.md
    └── Security-Controls.md
```

Copy the Scripts folder into the lab VM if needed. Adjust the working directory below to its actual location.

## Script behavior

| Script | Result |
| --- | --- |
| 01-Install-ADDS.ps1 | Installs AD DS/DNS, prompts for a DSRM password, creates the forest and automatically restarts. Run once on a fresh server. |
| 02-Create-OUs.ps1 | Creates 11 custom OUs; skips existing OUs. |
| 03-Create-Users.ps1 | Creates six enabled sample users; prompts for one temporary password and requires first-logon changes. Existing users are skipped. |
| 04-Create-Groups.ps1 | Creates seven global security groups and adds explicit memberships. |
| 05-Configure-GPOs.ps1 | Sets default password minimum length 10 and complexity; creates/reuses and links two initially empty GPOs. |
| 06-Configure-Shares.ps1 | Creates IT, HR, Developers, Management and Public shares under C:\LabShares; replaces their SMB and top-folder NTFS permissions. |
| 07-AD-Security-Audit.ps1 | Reports four account/group checks without modifying AD; overwrites its selected local output file. |

## Execution order

On the fresh server, open an elevated Windows PowerShell prompt:

```powershell
Set-Location 'F:\Active-Directory-Lab\Scripts'
.\01-Install-ADDS.ps1
```

If script execution is blocked, inspect `Get-ExecutionPolicy -List` and follow the lab's execution-policy requirements. For these reviewed files on an isolated VM, a session-only `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned` may be appropriate; organization-enforced policy takes precedence.

Enter a unique Directory Services Restore Mode (DSRM) recovery password and store it securely. It is separate from the sample-user password. **Promotion automatically restarts the server.** Wait for the domain to become available; do not rerun script 01 on the promoted server.

Sign in as `CYBERLAB\Administrator`, reopen Windows PowerShell as Administrator and return to the Scripts folder. Run the following **one at a time**, resolving errors before continuing:

```powershell
.\02-Create-OUs.ps1
.\03-Create-Users.ps1
.\04-Create-Groups.ps1
.\05-Configure-GPOs.ps1
.\06-Configure-Shares.ps1
.\07-AD-Security-Audit.ps1
```

For script 03, choose a temporary lab password meeting domain complexity requirements and at least 10 characters, anticipating script 05. A later policy change does not retroactively replace passwords. Complete first-logon password changes from the client before share testing.

Script 06 changes permissions on all five lab share folders on every run. Use dedicated empty folders, not existing business data. See [RBAC Design](RBAC-Design.md) before rerunning it.

The setup sequence assumes an administrative lab account. Elevation alone does not grant AD permissions. The audit needs AD read access and a writable report path; it does not inherently require Domain Admin privileges.

## Client and policy exercises

1. Set client DNS to the lab domain controller's IP and join cyberlab.local using an account authorized to join computers.
2. Restart the client as required.
3. On the server, use `dsa.msc` to move its computer account to CyberLab-Computers > Workstations. The scripts do not redirect default placement.
4. Configure the optional settings in [GPO Design](GPO-Design.md).
5. Test as an ordinary sample user. Do not move the domain controller out of its Domain Controllers OU.

## Verify the deployment

On the server:

```powershell
Import-Module ActiveDirectory
Get-ADDomain -Identity cyberlab.local
Get-ADDefaultDomainPasswordPolicy -Identity cyberlab.local |
    Select-Object MinPasswordLength, ComplexityEnabled
Get-SmbShare -Name IT, HR, Developers, Management, Public
Get-SmbShareAccess -Name HR
(Get-Acl -LiteralPath 'C:\LabShares\HR').Access
Get-Content -LiteralPath "$env:USERPROFILE\AD-Security-Audit.txt"
```

Use ADUC to verify the 11 custom OUs, six users and seven custom groups. Inspect both GPO links and actual configured settings in GPMC.

On a client, use `\\<SERVER-NAME>\HR` or `\\<SERVER-NAME>\Public`, replacing the placeholder with the real server hostname. Test allowed and denied operations using the identities in [RBAC Design](RBAC-Design.md). An administrator's successful access alone proves little about department isolation.

The audit defaults to the current user's profile and overwrites its report each run. A FAILED section means a check did not complete. See [Security Controls](Security-Controls.md) for exact coverage and timestamped-report guidance.

## Reruns and troubleshooting

- Scripts stop on failures, but earlier successful changes remain; there is no automatic rollback.
- Scripts 02–04 skip existing objects. They do not move users, repair existing group properties or remove extra memberships.
- Script 05 reapplies two password values and enables the specified links, preserving existing GPO settings.
- Script 06 replaces share/top-folder permissions; it does not recursively normalize existing child ACLs or change ownership.
- Confirm module availability, the signed-in identity and elevation when setup reports access errors.
- If the client cannot locate the domain, check DNS, network connectivity and time synchronization.
- If policy does not apply, check OU placement, scope and actual settings before treating an empty GPO as a failure.

## Reset and lab limits

For a clean rebuild, use the pre-promotion snapshot of this disposable isolated lab and rebuild or rejoin dependent clients as needed. This is not a production AD recovery procedure.

The lab has one domain controller, shared temporary sample credentials, manually configured policy exercises and a limited audit. Keep it isolated, use no personal or production credentials, and treat any generated reports as environment information.
