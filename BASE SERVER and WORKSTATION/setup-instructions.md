
---

### **setup-instructions.md**

```markdown
# Active Directory Lab Setup Instructions

This document provides detailed steps for setting up an Active Directory lab environment as demonstrated in [John Hammond's video tutorial](https://www.youtube.com/watch?v=pKtDQtsubio).

---

## Prerequisites

- **Hardware Requirements**:
  - A system with sufficient RAM (8GB minimum, 16GB recommended).
  - At least 50GB of available disk space.
- **Software Requirements**:
  - [VirtualBox](https://www.virtualbox.org/) and (VMware).
  - ISO images for:
    - Windows Server 2022
    - Windows 11

---

## Step 1: Install VirtualBox and VMware Workstation pro

1. Download VirtualBox from the [official website](https://www.virtualbox.org/) and VMware workstation pro from the [official website](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)
2. Install VirtualBox and VMware pro Workstation following the instructions for your operating system.
3. Optionally, install the VirtualBox Extension Pack for additional features.

---

## Step 2: Create Virtual Machines

### 2.1: Windows Server VM

1. Open VMware Workstation Pro and click **Create a New Virtual Machine** to create a new VM.
2. Configure the VM:
   - Name: `AD-Server`
   - Type: Microsoft Windows
   - Version: Windows Server 2022 (64-bit)
   - RAM: At least 4GB
   - Disk Space: 200GB dynamically allocated.
3. Attach the Windows Server 2022 ISO as the installation medium.
4. Boot the VM and complete the Windows installation process.
5. Configure the server and take the snapshot of the server in the VM ware workstation pro and we can sue this as our base server and workstation which we can use if something goes wrong during our later stages of the setup or enumeration.

---

### 2.2: Windows 11 VM

1. Create a new VM for Windows 11 following similar steps:
   - Name: `Workstation`
   - Type: Microsoft Windows
   - Version: Windows 11 Enterprise (64-bit)
   - RAM: 2GB
   - Disk Space: 100GB dynamically allocated.
2. Attach the Windows 11 ISO as the installation medium.
3. Install Windows 11 and create a local admin user account.
4. Configure the workstation
---

## Step 3: Configure Networking

1. Open VirtualBox and navigate to **File > Host Network Manager**.
2. Create a new host-only network:
   - IPv4 Address: `192.168.56.1`
   - Subnet Mask: `255.255.255.0`
3. Attach both VMs to this host-only network via their **Network Settings**.

---

## Step 4: Promote Windows Server to Domain Controller

1. On the Windows Server VM:
   - Open **Server Manager** and add the **Active Directory Domain Services (AD DS)** role.
2. Promote the server to a Domain Controller:
   - Create a new forest and domain (e.g., `lab.local`).
   - Set the Directory Services Restore Mode (DSRM) password.
3. Restart the server after the configuration is complete.

---

## Step 5: Join Windows 10 to the Domain

1. On the Windows 10 VM:
   - Open **System Properties** and navigate to the **Computer Name** tab.
   - Click **Change** and select **Domain**. Enter the domain name (e.g., `lab.local`).
2. Provide the credentials of a domain administrator when prompted.
3. Restart the workstation to apply changes.
4. Verify domain membership by logging in with a domain account.

---

## Step 6: Verify Setup

1. Test connectivity between the VMs:
   - From the Windows 10 VM, ping the Domain Controller’s IP (`192.168.56.101`).
2. Open **Active Directory Users and Computers (ADUC)** on the Domain Controller to verify the workstation is listed.

---

## Troubleshooting

- **Networking Issues**:
  - Ensure both VMs are on the same host-only network.
  - Verify static IP configurations.
- **Domain Join Failures**:
  - Check the DNS settings on the workstation.
  - Ensure the Domain Controller is online and reachable.

---

These steps complete the foundational setup of an Active Directory lab environment. The next steps involve exploring enumeration tools and techniques.
