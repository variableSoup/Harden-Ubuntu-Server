# Harden-Ubuntu-Server
A Bash script that automates the setup of a secure Linux server, including user management, firewall configuration (iptables/nftables), SSH hardening, and system monitoring.

# 🎯 What This Script Does
## ✔ Creates users:
- admin (with sudo access)
- _user1_ , _user2_ , _user3_ (regular users, no sudo)

## ✔ Sets up a firewall (iptables)
- Blocks all incoming connections except SSH (on port 2222)
- Allows loopback & ping
- Prevents unauthorized access

## ✔ Secures SSH
- Changes SSH port to 2222
- Disables root login
- Disables password authentication (only key-based login)
- Limits authentication attempts

## ✔ Configures Fail2Ban
- Prevents SSH brute-force attacks
- Bans IPs that fail 3 times for 10 minutes

## ✔ Installs system monitoring tools
- htop (Process monitoring)
- glances (System-wide resource monitoring)
- net-tools (Networking utilities)


