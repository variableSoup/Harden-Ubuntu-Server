#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define Users
ADMIN_USER="admin"
USERS=("user1" "user2" "user3")

# Secure SSH Port
SSH_PORT="2222"

# Function to create users
create_users() {
    echo "Creating users..."
    
    # Create admin user with sudo privileges
    sudo useradd "$ADMIN_USER"
    sudo usermod -aG sudo "$ADMIN_USER"
    
    # Create standard users with no sudo privileges
    for USER in "${USERS[@]}"; do
        sudo useradd "$USER"
        mkhomedir_helper "$USER"
    done

    echo "Users created successfully!"
}

# Configure Firewall (iptables)
setup_firewall() {
    echo "Setting up firewall..."

    #install iptables
    sudo apt install -y iptables
    
    # Flush existing rules
    sudo iptables -F
    
    # Set default policies
    sudo iptables -P INPUT DROP
    sudo iptables -P FORWARD DROP
    sudo iptables -P OUTPUT ACCEPT

    # Allow incoming SSH (change port if needed)
    sudo iptables -A INPUT -p tcp --dport $SSH_PORT -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

    # Allow loopback (localhost) traffic
    sudo iptables -A INPUT -i lo -j ACCEPT

    # Allow established connections
    sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Allow ping requests
    sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

    # Save iptables rules
    sudo iptables-save > /etc/iptables.rules
    echo "iptables-restore < /etc/iptables.rules" >> /etc/rc.local
    
    echo "Firewall configured!"
}

# Secure SSH Configuration
secure_ssh() {
    echo "Hardening SSH configuration..."

    #Install SSH
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    
    # Backup existing SSH config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    
    # Configure SSH settings
    echo "Editing ssh_config file. . ."
    sudo sed -i "s/#Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
    sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/g' /etc/ssh/sshd_config
    sudo sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 300/g' /etc/ssh/sshd_config
    sudo sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/g' /etc/ssh/sshd_config

    # Restart SSH service
    sudo systemctl enable ssh
    echo "SSH secured!"
}

# Install and Configure Fail2Ban
setup_fail2ban() {
    echo "Installing and configuring Fail2Ban..."
    
    sudo apt update && apt install -y fail2ban
    
    # Configure Fail2Ban for SSH
    cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 600
findtime = 600
EOF

    sudo systemctl enable fail2ban
    echo "Fail2Ban installed and configured!"
}

# Install System Monitoring Tools
setup_monitoring() {
    echo "Installing system monitoring tools..."

    sudo apt install -y htop glances net-tools
    
    echo "System monitoring tools installed!"
}

# Execute functions
echo "Starting Ubuntu Server Security Setup..."

create_users
setup_firewall
secure_ssh
setup_fail2ban
setup_monitoring

echo "Security setup completed successfully! 🚀"