#!/bin/bash

# =============================================
# 1-Click Gensyn Node Install Toolkit (Complete Version)
# =============================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Global variables
USERNAME=$(whoami)
NEED_REBOOT=0

# ========================
# Utility Functions
# ========================

# Check if command executed successfully
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1 failed.${NC}"
        exit 1
    fi
}

# Print section header
section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Print status message
status() {
    echo -e "${GREEN}[+]${NC} $1"
}

# Check if package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
    return $?
}

# ========================
# Installation Functions
# ========================

install_basics() {
    section "System Setup"
    status "Updating system packages..."
    sudo apt-get update && sudo apt-get upgrade -y
    check_success "System update"
    
    status "Installing essential tools..."
    sudo apt-get install -y \
        screen curl iptables build-essential git wget lz4 jq make gcc \
        nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config \
        libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip \
        libleveldb-dev ufw fail2ban chrony libtool
    check_success "Essential tools installation"
    
    # Enable UFW firewall
    sudo ufw allow ssh
    sudo ufw allow 26656/tcp  # Default Tendermint port
    sudo ufw enable
}

install_go() {
    section "Installing Go (Optional)"
    read -p "Install Go? (y/n, default=n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        local GO_VERSION="1.21.0"
        wget "https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "go$GO_VERSION.linux-amd64.tar.gz"
        rm "go$GO_VERSION.linux-amd64.tar.gz"
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
        source ~/.bashrc
        status "Go installed: $(go version)"
    else
        status "Skipping Go installation."
    fi
}

setup_swap() {
    section "Swap Configuration"
    
    # Check if swap already exists
    if swapon --show | grep -q "/swapfile"; then
        status "Swap already configured"
        return
    fi
    
    status "Creating 8GB swap file..."
    sudo fallocate -l 8G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    
    # Make permanent
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    
    # Optimize swappiness
    sudo sysctl vm.swappiness=10
    sudo sysctl vm.vfs_cache_pressure=50
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
    echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
    
    check_success "Swap configuration"
}

setup_time_sync() {
    section "Time Synchronization"
    
    status "Configuring Chrony..."
    sudo timedatectl set-timezone UTC
    sudo systemctl enable chrony
    sudo systemctl start chrony
    
    status "Current time status:"
    timedatectl status
    chronyc tracking
}

install_docker() {
    section "Installing Docker"
    sudo apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo docker run hello-world
    check_success "Docker installation"
}

install_python() {
    section "Installing Python"
    sudo apt-get install -y python3 python3-pip python3-venv python3-dev
    check_success "Python installation"
    status "Python version: $(python3 --version)"
    status "Pip version: $(pip3 --version)"
}

install_node() {
    section "Installing Node.js & Yarn"
    sudo apt-get update
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
    check_success "Node.js installation"
    status "Node version: $(node -v)"
    status "NPM version: $(npm -v)"

    # Install Yarn (both methods for redundancy)
    sudo npm install -g yarn
    curl -o- -L https://yarnpkg.com/install.sh | bash
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
    echo 'export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    check_success "Yarn installation"
    status "Yarn version: $(yarn --version)"
}

clone_repo() {
    section "Cloning RL-Swarm Repository"
    if [ -d "rl-swarm" ]; then
        status "Repository already exists, pulling latest changes..."
        cd rl-swarm
        git pull
        cd ..
    else
        git clone https://github.com/gensyn-ai/rl-swarm/
        check_success "Repository cloning"
    fi
    status "Repository ready at: $(pwd)/rl-swarm"
}

cleanup() {
    section "Cleaning Up"
    sudo apt-get autoremove -y
    sudo apt-get clean
}

# ========================
# Main Execution
# ========================

echo -e "\n${GREEN}=== Starting 1-Click Node Installation ===${NC}"

install_basics
setup_time_sync
install_docker
install_python
install_node
clone_repo
setup_swap
cleanup

# Final output
echo -e "\n${GREEN}=== Installation Complete! ===${NC}"
echo -e "The following components were installed:"
echo -e " - System updates and essential tools"
echo -e " - Docker with user permissions"
echo -e " - Go programming language"
echo -e " - 4GB swap file"
echo -e " - Time synchronization with Chrony"
echo -e " - Basic security (UFW firewall)"

if [ $NEED_REBOOT -eq 1 ]; then
    echo -e "\n${YELLOW}NOTE: You need to REBOOT for all changes to take effect (especially Docker group permissions).${NC}"
    echo -e "After reboot, you can verify with: docker ps"
fi

echo -e "\nNext steps:"
echo -e "1. Install your specific node software"
echo -e "2. Configure your node"
echo -e "3. Set up monitoring (optional)"
