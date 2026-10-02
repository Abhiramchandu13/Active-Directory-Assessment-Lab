# Active Directory Design
## Domain and OU structure

- DNS domain: `cyberlab.local`
- NetBIOS name: `CYBERLAB`
- Domain DN: `DC=cyberlab,DC=local`
- Lab server: Windows Server 2019 or 2022, running AD DS and DNS.

Script 02 creates 11 custom OUs:

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

This diagram shows custom OUs only. Default containers and the Domain Controllers OU remain. Keep the domain controller in the Domain Controllers OU; the Servers OU is intended for member servers.

| OU | Purpose and current implementation |
| --- | --- |
| CyberLab-Users | Parent for the five departmental user OUs populated by script 03. |
| CyberLab-Computers/Workstations | Intended for joined clients; target of the workstation GPO link. Placement is manual. |
| CyberLab-Computers/Servers | Intended for member servers; no servers are created or moved by these scripts. |
| CyberLab-Groups | Holds the seven custom global security groups created by script 04. Built-in groups remain in their existing locations. |
| CyberLab-ServiceAccounts | Reserved for future service-account exercises; the scripts create no service accounts or logon restrictions. |

## User placement

| Username | Name | Departmental OU |
| --- | --- | --- |
| jdoe | John Doe | IT |
| asmith | Alice Smith | HR |
| rbrown | Robert Brown | Developers |
| swilson | Sarah Wilson | Management |
| dmiller | David Miller | Developers |
| edavis | Emily Davis | Interns |

Script 03 sets names, usernames, UPNs and OU placement. It does not populate the Department or job-title attributes. New accounts are enabled, share a prompted temporary lab password and must change it at first logon. Existing users are skipped without password resets or placement repairs.

OU placement does not automatically assign group membership. Script 04 explicitly adds the memberships listed in [RBAC Design](RBAC-Design.md).

## Policy and administration boundaries

OUs organize objects and provide targets for policy links and delegated permissions. Creating an OU alone does not restrict access, grant administrative rights, or delegate administration. These scripts do not configure delegation.

GPOs can be linked to sites, domains and OUs. User settings normally follow the user object; computer settings follow the computer object. Security filtering, inheritance and other processing rules also affect application. See [Microsoft's Group Policy scope documentation](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-scope).

The two custom GPOs start empty. Their exact links and the separate domain password changes are documented in [GPO Design](GPO-Design.md).

A service-account OU is an organizational aid. To restrict local or Remote Desktop logon, configure the relevant computer-side user-rights settings on the target computers and identify the accounts or groups to deny. Linking those computer settings only to an OU containing service users does not apply them to workstations.

## Object placement and reruns

Creating these OUs does not redirect default user or computer creation locations. Move a joined client's computer object into Workstations using Active Directory Users and Computers (`dsa.msc`), or explicitly select that OU during provisioning.

Script 02 skips existing OUs. Scripts 03 and 04 do not reconcile all existing state: they do not move existing accounts, repair existing group scope/category, or remove extra memberships.

## Verification

On the lab domain controller:

```powershell
Import-Module ActiveDirectory
Get-ADOrganizationalUnit -Filter * -SearchBase 'DC=cyberlab,DC=local' |
    Select-Object Name, DistinguishedName
Get-ADUser -Filter * -SearchBase 'OU=CyberLab-Users,DC=cyberlab,DC=local' |
    Select-Object SamAccountName, Enabled, DistinguishedName
Get-ADComputer -Filter * |
    Select-Object Name, DistinguishedName
```

Compare the results with the expected custom OUs and six sample users. Existing domain objects may add to the results.

## Future exercises

Separate daily-use and administrative identities, delegate a limited OU task, and design service-account lifecycle management. These are proposed exercises, not controls implemented by the scripts.
