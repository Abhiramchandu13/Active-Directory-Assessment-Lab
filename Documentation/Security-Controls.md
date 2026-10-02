# Security Controls

## Implemented behavior and its limits

| Area | Script behavior | Limit |
| --- | --- | --- |
| Domain authentication | Script 01 installs AD DS/DNS and creates cyberlab.local. | Domain membership does not eliminate member-computer local accounts. |
| Directory organization | Script 02 creates 11 custom OUs. | OU placement alone grants no restrictions or administrative delegation. |
| Sample credentials | Script 03 prompts securely for a shared temporary password and requires a first-logon change for new users. | Shared initial credentials are a lab convenience; existing accounts are skipped. |
| Role groups | Script 04 creates seven global security groups and adds specified members. | No Domain Admin elevation or delegated administration is configured; extra existing memberships remain. |
| Default password policy | Script 05 sets minimum length 10 and enables complexity. | No explicit lockout, password-history or password-age configuration; verify effective policy. |
| GPO preparation | Script 05 creates/reuses and links two initially empty GPOs. | Firewall, audit logging, screen saver and logon restrictions require manual configuration. |
| File access | Script 06 sets SMB and NTFS permissions for five shares. | Existing child-item ACLs and partial failures can affect access; test with ordinary users. |
| Basic AD inventory | Script 07 runs four reporting checks without changing AD. | It writes a local report and does not verify the other controls. |

See [GPO Design](GPO-Design.md) and [RBAC Design](RBAC-Design.md) for exact settings and verification.

## Service accounts

CyberLab-ServiceAccounts is an empty OU reserved for exercises. No service accounts, managed service accounts, credential rotation or interactive-logon restrictions are created. An OU is not itself a security restriction. Any future deny-logon policy must reach the target computers and specify the relevant accounts or groups.

## Exact audit coverage

Script 07 reports:

1. Direct Domain Admins members.
2. Domain Admins members resolved recursively through nested groups.
3. Enabled users whose passwords never expire.
4. Disabled users.

It does not inspect GPO settings, SMB/NTFS permissions, effective password rules, stale accounts, event-log auditing, encryption, patch status, or every privileged group.

Disabled accounts are not automatically vulnerabilities. Non-expiring-password results require context. A report with no matching objects is not a security certification.

By default, the report is `$env:USERPROFILE\AD-Security-Audit.txt`. Every run overwrites that file. Use a unique filename in an existing, appropriately restricted directory to preserve evidence:

```powershell
$Report = Join-Path $env:USERPROFILE ("AD-Security-Audit-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
.\07-AD-Security-Audit.ps1 -OutputFile $Report
Get-Content -LiteralPath $Report
```

Run this from the Scripts directory on the lab server. Each failed query is recorded as FAILED; the script continues other queries and throws after the loop if any query failed. A module-import or report-write failure can stop execution earlier. A failed check means unknown results, not an empty finding.

## Verification evidence to collect

| Area | Evidence |
| --- | --- |
| Domain and OU setup | ADUC or Get-ADDomain/Get-ADOrganizationalUnit results. |
| Group membership | Get-ADGroupMember output for the seven custom groups and relevant privileged groups. |
| Password rules | Get-ADDefaultDomainPasswordPolicy output after policy processing. |
| Manual GPO exercises | Actual configured settings, client gpresult output and observed behavior. |
| Share access | SMB and NTFS ACL output plus successful and denied operations as ordinary users. |
| Audit completion | Timestamped report with all four sections and no FAILED checks. |

Keep reports and screenshots free of entered passwords and protect them as environment information. No runtime results were collected during this documentation review.

## Lab limitations

- A single domain controller provides no redundancy; departmental shares also reside there in this simplified setup.
- The scripts do not enforce LDAP/SMB encryption settings or test transport security.
- GPO names alone do not establish a security baseline.
- No MFA integration, Windows LAPS, application control, centralized logging, EDR deployment, backup testing or administrative tier separation is configured.
- Provisioning is not transactional. Reruns do not fully reconcile every object or child-item permission.
- The shared temporary user password and broad IT share Full permission are deliberate teaching simplifications.

## Future exercises

Prioritize verifying the current configuration, separating daily-use and administrative accounts, and documenting tested recovery procedures. Then add managed service accounts, workstation password management, scoped audit policies and centralized monitoring as separate exercises.

Any certificate-services or MFA work needs its own design and testing; adding a certificate authority alone does not enable encryption for every protocol. These capabilities are outside the current scripts.
