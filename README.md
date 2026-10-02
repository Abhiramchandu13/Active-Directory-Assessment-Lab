# Active-Directory-Assessment-Lab

# This is a Enterprise level  Active Directory Security Assessment Lab

## Overview

The Enterprise Active Directory Security Assessment Lab is a virtual enterprise environment designed to simulate a real-world Windows domain for learning Active Directory administration and internal penetration testing. The project demonstrates how enterprise authentication, access control, and security policies are implemented while providing a controlled environment to assess common Active Directory security risks.

---

## Problem Statement

Active Directory is widely used to manage users, devices, and resources in enterprise environments. Misconfigurations in user permissions, password policies, Group Policy Objects (GPOs), and shared resources can expose organizations to unauthorized access and privilege escalation.

This project was developed to simulate an enterprise network where Active Directory security controls can be implemented, validated, and assessed in a safe laboratory environment.

---

## Objectives

- Build a realistic enterprise Active Directory environment.
- Configure centralized authentication and authorization.
- Implement security policies using Group Policy.
- Secure shared resources with role-based access control.
- Perform internal security assessment in a controlled environment.
- Document findings and recommend security best practices.

---

## Lab Architecture

```
                VMware Workstation

        +----------------------------+
        |                            |
        |      Windows Server 2019   |
        |      Domain Controller     |
        |      AD DS + DNS           |
        +-------------+--------------+
                      |
        ------------------------------
        |                            |
+-------------------+      +------------------+
| Windows 10 Client |      | Kali Linux       |
| Domain Joined     |      | Security Testing |
+-------------------+      +------------------+
```

---

## Features

- Active Directory Domain Services (AD DS)
- DNS Configuration
- Organizational Units (OUs)
- User & Group Management
- Group Policy Objects (GPOs)
- Password & Account Lockout Policies
- Shared Folder Configuration
- NTFS & SMB Permissions
- Domain Authentication
- Role-Based Access Control (RBAC)

---

## Technologies Used

| Category | Technologies |
|----------|--------------|
| Operating Systems | Windows Server 2019, Windows 10, Kali Linux |
| Directory Services | Active Directory Domain Services |
| Networking | DNS, SMB |
| Security | Group Policy, NTFS Permissions |
| Virtualization | VMware Workstation |
| Scripting | PowerShell |

---

## Project Structure

```
Enterprise-AD-Security-Lab/

│── Documentation/
│── Evidence/
│── Architecture/
│── Reports/
│── Scripts/
│── README.md
```

---

## Security Controls Implemented

- Password Complexity Policy
- Account Lockout Policy
- Role-Based Access Control
- Organizational Unit Management
- Shared Folder Permissions
- NTFS File Security
- Group Policy Enforcement

---

## Project Outcomes

- Successfully deployed a Windows Active Directory enterprise environment.
- Implemented centralized authentication and authorization.
- Configured enterprise security policies using Group Policy.
- Protected network resources through group-based permissions.
- Prepared the environment for internal penetration testing and security assessments.

---

## Future Enhancements

- Active Directory Enumeration using BloodHound
- SMB & LDAP Security Assessment
- Kerberos Attack Simulation
- Wazuh SIEM Integration
- Automated Security Auditing with PowerShell
- Active Directory Hardening using Microsoft Security Baselines

---

## Learning Outcomes

Through this project, I gained practical experience in:

- Active Directory Administration
- Windows Server Management
- Enterprise User & Group Management
- Group Policy Configuration
- Windows Security Best Practices
- Enterprise Access Control
- Security Documentation

---

## Disclaimer

This project was developed in an isolated virtual lab for educational purposes only. All security assessments and configurations were performed in a controlled environment.
