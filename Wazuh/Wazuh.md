# Installing and configuring Wazuh Server to Our AD

# Introduction to Wazuh
* Wazuh is an open-source security platform designed to unify threat detection, intrusion detection, and compliance management across diverse infrastructures. It extends the OSSEC project with comprehensive monitoring for file integrity, configuration assessment, and real-time security analytics. Wazuh’s modular architecture makes it suitable for a wide range of environments, including on-premises, cloud-based, and containerized deployments. By collecting and analyzing security data from hosts and networks, Wazuh helps organizations swiftly detect malicious activity, automate incident response, and maintain compliance with industry standards.

* For my local lab I am going to download install and configure wazuh on an ubuntu server. We can configure it in windows systems as well. I followed the official guide on the wazuh website and followed the steps along and installed it. You can find it below
     Link - https://documentation.wazuh.com/current/quickstart.html

* I installed a basic Ubuntu 22.04 in my VMware Workstation and gave it 8GB RAM, 50 GB storage and 2 cores of processor, which should be good enough to handle the server.
![alt text](./Media/image.png)

# Joining Ubuntu to AD

* To join a debain based OS to AD directory is a little different approach than the usual joining of windows system to the AD. We will need to install some of the required tools which can be done by running the following command in the terminal.
```
    sudo apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit
```
* This will install the required packages on the ubuntu machine.

* Next we will be changing the hostname of our ubuntu machine and put it according to our domain name.
```
    sudo hostnamectl set-hostname hostname.domain.local
```
- change "hostname.domain.local" according to your domain and the hostname you want to give to your server. In my case it was "wazuh.hackerspace.com"
![alt text](./Media/image-1.png)

* Now lets change the dns settings in our ubuntu machine. For that we will first disable the systemd-resolved service and stop it
```
    sudo systemctl disable systemd-resolved.service
    sudo systemctl stop systemd-resolved.service
```
![alt text](./Media/image-2.png)

* Now lets edit the resolv.conf file and point this towards our domain.
```
    sudo nano /etc/resolv.conf
```
edit the name server IP with the IP of your DC.
![alt text](./Media/image-3.png)

* Once we change that we will use the *realm* command to join the machine to the AD. REALM is on of the packages that we installed earlier which is a tool used to join to different domain, in our case its going to be AD.
But first lets see if the ubuntu server is able to map our domain.
```
    sudo realm discover domain.local
```
![alt text](./Media/image-4.png)

* This shows that we are able to resolve the domain correctly.
* To join the machine to the domain we will use the below command.
```
    sudo realm join -U Administrator domain.local
```
![alt text](./Media/image-5.png)

* The *realm list* will tell us what domain we are joined to.
* Now that our machine is joined to the domain we will setup the authentication setup as we can see in the screenshot that the software the client is using is "sssd" and we have also installed this package as part of our top command.

* SSSD (System Security Services Daemon) is a central authentication and identity management solution for Linux systems. It seamlessly integrates local hosts with remote directories or identity providers (such as LDAP, Active Directory, or FreeIPA), caching credentials for offline access. By unifying user information and providing a single point of configuration, SSSD simplifies authentication, enhances security, and improves performance across diverse environments.
* So as there are going to be a lot of accounts that now access the ubuntu machine we will have to setup the home directory setup for each of the account as in when they login to the machine.

*NOTE: At this point I will advice that you take a snapshot of your machine just incase anything goes wrong while setting up the home directory configuration setting the machine will be broken and of no use and we will have to start from point1. So it is a good practice to take the snapshot of the machine and then we can move ahead*

* To edit the necessary file we will use the below command to change the necessary changes.
```
    sudo nano /usr/share/pam-configs/mkhomedir
```
![alt text](./Media/image-6.png)

* we changed the default to yes and priority to 900 and also we can get rid of the session interactive only part
* Once we are done with that we will have seperate directories for each user whenever they login.
![alt text](./Media/image-7.png)

* Now that all the authentication is set lets now setup and configure ssh for all these users such that they can have a secure shell when required. For that we will use the realm command once again
```
    sudo realm permit
```
* After "permit" you can mention users, groups or individual users who you want to grant access to.

* Now to give all the domain admins on in our Domain or any other groups that we want to have the sudo access on the machine we can do that from regular sudoers file. But we will be creating a different file naming the domainadmins. in that file we shall put the below line
```
    %domain\ admins@hackerspace.com  ALL=(ALL) ALL
```
After this is done the domain admins in our domain should be able to have all the sudo access on this server.
*  Now that we have set everything in place. We have laid the ground for our Wazuh server.

# Installing and setting up Wazuh:

* To set our own wazuh server in our own home lab or corporate network we can follow the Wazuh quickstart guide on their website. 
https://documentation.wazuh.com/current/quickstart.html

* Installing wazuh consists of setting up 3 parts of Wazuh
    1. Wazuh Server
    2. Wazuh Indexer
    3. Wazuh Dashboard.
* Now if we want we can always setup these individually as well, but I am following the basic installation and we can do it by using the single line command given in their quickstart guide.
```
    curl -sO https://packages.wazuh.com/4.11/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
```
This command will download and install the dependencies and packages required and and setup the Wazuh for us.
![alt text](./Media/image-8.png)
* Once wazuh is installed ans configured the installation will give us the username and password with which we can access the dashboard.
![alt text](./Media/image-9.png)

And we can access the dashboard by visiting the https://YOUR_SERVER_IP:443 and provide the username and password.
![alt text](./Media/image-10.png)


* Wazuh serves as our unified platform for threat detection, intrusion detection, and compliance monitoring across heterogeneous environments. To enrich its telemetry and extend endpoint visibility, I will integrate Microsoft Sysmon logs into the Wazuh manager. By ingesting and parsing Sysmon event IDs (e.g., process creation 1, network connection 3, DNS query 22), we can define custom decoders and rules so that Wazuh raises high‑fidelity alerts whenever suspicious or anomaly‑based Sysmon events are captured, thereby tightening endpoint detection and response (EDR) coverage across the estate.

* For that we will have to deploy sysmon on all of our workstations as a startup script in order for all the machines to have sysmon installed when they are rebooted the next time.
* We will go to the Group policy manager > Right click at the domain level > Create a new policy > Name it as Sysmon > Computer Configuration > Windows Settings > Scripts > Startup Scripts > Powershell scripts and write a script such that the system installs sysmon and configures it.

https://wazuh.com/blog/using-wazuh-to-monitor-sysmon-events/

* I have provided a sample sysmon.ps1 code that you can refer to install sysmon as a startup script.

* For us to configure sysmon such that it filters the even and our wazuh agent can scan those events too and create an alert and make a not of it such that we can view it in the Wazuh Dashboard we will install the latest sysmon.xml file uploaded by Wazuh itself and use it. Wazuh maintains its own sysmon xml file which has all the rules to create an alert with all the latest vulnerabilities that have been detected. 

https://wazuh.com/blog/

* Now the same way that we installed sysmon we need to install the wazuh agents on our workstations using the same strtup script method.

* Usually you can just install the agent download it and deploy it in your workstations. But as we know in an enterprise network we will have 10's and 100's of machines so deploying wazuh agent with the use of group policy is the best idea to do. 

* Once we have deployed the scripts and agent is installed it is now for us to move ahead and confugure wazuh with the sysmon events

* We will follow the steps mentioned in the above listed website for our reference.

1. Deploy Sysmon and Wazuh using startup script
2. Edit the wazuh ossec.conf file with the below code ush that it monitors all the events from the sysmon too.
```
    <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
    </localfile>
```

3. Configure the Wazuh manager by editing the local_rules.xml file to macth with the sysmon evnts being created.

* Once we have installed Wazuh the workstations it should be available in the installed apps section.
![alt text](./Media/image-11.png)

* And in our Wazuh manager we should see our machine as active.
![alt text](./Media/image-12.png)

* Now that our machine is active we can see the dashboard with all the information that wazuh has created about it.
![alt text](./Media/image-13.png)

* To see the better dashboard of our Vulnerabilities we can click on the Vulnerability section of the machine and see all the severe vulnarabilities our machine has and create alerts accordingly.
![alt text](./Media/image-14.png)

With Wazuh now fully integrated into our Active Directory environment—collecting Sysmon telemetry, correlating it with host and network data, and surfacing high‑fidelity alerts in the dashboard—we have laid the groundwork for a mature, end‑to‑end detection‑and‑response pipeline. From here the focus shifts to **continuous tuning**: refine Sysmon XML filters to cut noise, expand Wazuh decoders and rules for new threat techniques, and integrate ticketing or SOAR hooks to automate containment and remediation. Periodic vulnerability scans, purple‑team simulations, and dashboard reviews will ensure that Wazuh remains aligned with evolving adversary tactics and organizational risk. In short, this deployment is not a finish line but a foundation—one that equips us to detect faster, respond smarter, and satisfy compliance mandates as our infrastructure grows.