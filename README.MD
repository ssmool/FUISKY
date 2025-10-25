FUISKY - Fujizksy Security & Network Console

Overview

FUISKY is a powerful and flexible **cross-platform security and network monitoring tool**. Developed by **asytrick**, it enables users to efficiently manage their system's security settings, monitor network traffic, and apply firewall rules. Whether you're securing a Linux server, a macOS workstation, or an Android device, **FUISKY** offers customizable options for securing your environment.

Key Features:

Network Monitoring**: View active network connections, identify programs and PIDs, and manage blocked IPs.
Process and Resource Management**: Monitor CPU, RAM, and Disk usage with easy-to-read reports, and manage process forks.
Firewall Configuration**: Set and adjust multiple security levels (Basic, Medium, Hard) using built-in firewall tools (`iptables`, `pfctl`, etc.).
Security Hardening**: Disable unnecessary services, enhance system security, and lock down the device or network settings.
Cross-Platform Support**: Works on **Linux**, **FreeBSD**, **macOS**, and **Android (with root)**.
Perl Integration**: Run shell scripts from Perl, enabling easy automation and configuration.
Automated Setup**: Simplified installation and configuration guide to help you set up FUISKY and get started quickly.

---

⚙️ How to Use

Save as fujizksy.sh

Make executable:

```bash
chmod +x fujizksy.sh
```

## 3.Run as root (required for firewall/process actions):

```bash
sudo ./fujizksy.sh
#For all platforms or crossover use the script: ./fujizksy_all.sh

```

🧠 Notes

Works on Linux, can be adapted for FreeBSD/macOS (replace iptables with pfctl or nft).

Requires basic tools: netstat, ps, top, nmcli, iptables.

Add more commands in each section if needed (like nmap, ss, etc.).
---

Contact

This project is maintained by **asytrick**.

You can contact the author at:
**Email**: [eusmool@gmail.com](mailto:eusmool@gmail.com)

---

Documentation

For detailed documentation, guides, and setup instructions, refer to the **[manual.mdf](https://github.com/ssmool/FUISKY/manual.mdf)**.

---

Hashtags

#FUISKY #NetworkSecurity #SystemHardening #FirewallManagement #LinuxSecurity #FreeBSD #macOSSecurity #AndroidSecurity #AndroidApp #CPlusPlus #PerlScript #Automation #OpenSource #CyberSecurity #NetworkMonitoring #Firewall #SecurityTools #SysAdmin #CrossPlatform #Fujizksy

