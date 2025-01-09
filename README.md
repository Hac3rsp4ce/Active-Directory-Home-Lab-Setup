# Active Directory Lab Setup

This repository documents the setup of an Active Directory lab environment inspired by [John Hammond's video tutorial](https://www.youtube.com/playlist?list=PL1H1sBF1VAKVoU6Q2u7BBGPsnkn-rajlp). The lab provides a foundational environment for practicing Active Directory enumeration, exploitation, and security assessments.

## Purpose

The goal of this setup is to:
- Create a controlled virtual environment for learning and practicing Active Directory concepts.
- Serve as a testing ground for enumeration techniques and security tools.
- Establish a basic domain infrastructure for further exploration and testing.

## Tools Used

- **Virtualization Software**: VirtualBox and VMware Workstation Pro
- **Operating Systems**:
  - Windows Server 2022 (configured as a Domain Controller)
  - Windows 11 (joined to the domain)
  - HTB Parrot OS (Enumerating the domain)
- **Networking Configuration**: Host-only networking setup for communication between VMs.

## Lab Setup Overview

1. **Installed VirtualBox** and configured the virtualization environment.
2. **Created Virtual Machines**:
   - Windows Server 2022 for the Domain Controller.
   - Windows 11 for the workstation joined to the domain.
   - HTB Parrot OS (for enumerating the domain and testing attack vectors)
3. **Configured Networking**:
   - Set up host-only networking for isolated communication.
4. **Promoted Windows Server to a Domain Controller**:
   - Created a new forest and domain.
5. **Joined Windows 11 Workstation to the Domain**:
   - Configured DNS to point to the Domain Controller.
   - Added the workstation to the domain.

## Repository Structure

```plaintext
ad-lab-setup/
├── README.md                # Overview of the repository
├── setup-instructions.md    # Detailed setup steps
├── media/                   # Screenshots of the lab setup
├── configurations/          # Configuration files and settings
├── scripts/                 # Automation scripts (if any)
└── LICENSE                  # Repository license



Today we did
Cloning the Server and workstation and setting one of the server as domain controller and the workstation as a management console and enabled PS remoting

Added the created domain controller as a trusted host from the management console and configured the WinRM of the domain controller and entered the PS session remotely from the management console

link for more documentation on how to add a server to a server manager using trusted hosts https://learn.microsoft.com/en-us/windows-server/administration/server-manager/add-servers-to-server-manager

![image](https://github.com/user-attachments/assets/f5ec3665-c9a1-4aaa-a493-2a3649031933)
