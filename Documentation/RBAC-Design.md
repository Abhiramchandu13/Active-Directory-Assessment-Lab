# Role-Based Access Control (RBAC) Design
## Groups and explicit memberships

Script 04 creates these **global security groups** in CyberLab-Groups and adds the following memberships:

| Group | Members added by the script |
| --- | --- |
| IT-Admins | jdoe |
| IT-Support | jdoe |
| HR-Team | asmith |
| Developers | rbrown, dmiller |
| Management | swilson |
| Interns | edavis |
| Security-Team | jdoe, rbrown |

These are explicit mappings, not dynamic membership based on OU placement. Existing extra members are not removed on rerun.

IT-Admins is a custom group. Its name grants no domain administrative privilege. The scripts do not add these groups or sample users to Domain Admins, grant local administrator membership, or delegate AD administration. Interns and Security-Team receive no explicit share permissions from script 06.

## Share and NTFS permissions

Script 06 creates shares on the machine running it, with folders under `C:\LabShares` by default.

| Share | Department/group | SMB permission | NTFS permission |
| --- | --- | --- | --- |
| IT | CYBERLAB\IT-Admins | Full | FullControl |
| IT | CYBERLAB\IT-Support | Change | Modify |
| HR | CYBERLAB\HR-Team | Change | Modify |
| Developers | CYBERLAB\Developers | Change | Modify |
| Management | CYBERLAB\Management | Change | Modify |
| Public | CYBERLAB\Domain Users | Read | ReadAndExecute |

CYBERLAB\Domain Admins receives SMB Full and NTFS FullControl for all five shares. SYSTEM and BUILTIN\Administrators also receive explicit NTFS FullControl. Domain users can read Public through their normal Domain Users membership.

For network file access, both SMB and NTFS permissions must allow the operation. Local file access does not pass through the SMB permission layer. Multiple group memberships and any existing child-item ACLs affect effective access.

For example:

```text
asmith → HR-Team → \\<SERVER-NAME>\HR → SMB Change + NTFS Modify
```

Replace `<SERVER-NAME>` with the actual lab server hostname. Alice can create, edit and delete files in the HR folder under the expected fresh-lab ACLs. She has no department-group grant to IT. John belongs to both IT groups, so his IT access includes Full permissions; the lower IT-Support grant does not cap his access.

## Rerun behavior and limits

Script 06 replaces SMB permissions and the NTFS ACLs on the five share folders. It removes inherited permissions from those folders and installs the defined explicit rules. It preserves ownership and does not recursively reset custom explicit ACLs or disabled inheritance on existing child items.

Use dedicated, initially empty lab folders. Existing shares pointing to different paths cause the script to stop before permission changes. A later runtime failure can still leave partial changes; there is no automatic rollback.

The `-ShareRoot` parameter changes the intended folder root, not the location of existing shares. Use the same root on reruns. The `-Domain` parameter changes account-name prefixes for this script only; it does not parameterize the other scripts' fixed domain.

## Verify access as ordinary users

On the server:

```powershell
Get-ADGroupMember -Identity HR-Team
Get-SmbShareAccess -Name HR
(Get-Acl -LiteralPath 'C:\LabShares\HR').Access
```

Adjust the ACL path if a custom ShareRoot was used. On a domain-joined client, complete each user's initial password change and sign out and back in after membership changes. Use separate user sessions to avoid reusing another user's SMB credentials.

| Test identity | Expected fresh-lab result |
| --- | --- |
| asmith | Can create, edit and delete test files in HR; cannot access IT through its department grants. |
| rbrown or dmiller | Can create and edit files in Developers; no department-group access to HR. |
| edavis | Can read an administrator-created test file in Public; cannot create files there. |
| jdoe | Full access to IT through IT-Admins; membership does not grant domain administration. |

Testing only as Domain Administrator does not validate department restrictions. Unexpected access requires reviewing both ACL layers, nested memberships, child-item permissions and the actual authenticated identity.

## Future improvements

An AGDLP model (Accounts → Global groups → Domain Local groups → Permissions) can separate job-role membership from resource permissions, including in a single-domain environment. The current scripts grant permissions directly to global groups. Separate administrative identities, delegated roles and time-limited privileged access are additional exercises, not implemented features.
