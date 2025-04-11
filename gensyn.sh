#!/bin/bash

# Auto-Install Script for Dependencies
# This script will install all required packages and tools

# Function to print section headers
print_section() {
    echo ""
    echo "###############################################"
    echo "### $1"
    echo "###############################################"
    echo ""
}

# Exit on error
set -e

print_section "1. Updating System Packages"
sudo apt-get update && sudo apt-get upgrade -y

print_section "2. Installing General Utilities and Tools"
sudo apt install -y \
    screen curl iptables build-essential git wget lz4 jq \
    make gcc nano automake autoconf tmux htop nvme-cli \
    libgbm1 pkg-config libssl-dev libleveldb-dev tar clang \
    bsdmainutils ncdu unzip nvtop htop libleveldb-dev netcat-traditional

print_section "3. Installing Python"
sudo apt-get install -y python3 python3-pip python3-venv python3-dev

print_section "4. Installing Node.js"
sudo apt-get update
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
echo "Node.js version: $(node -v)"

print_section "5. Installing Yarn"
# Install Yarn through npm first
sudo npm install -g yarn
echo "Yarn version: $(yarn -v)"

# Then install using the recommended method
curl -o- -L https://yarnpkg.com/install.sh | bash
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
source ~/.bashrc

print_section "Installation Complete!"
echo "All dependencies have been installed successfully."
echo "Node.js version: $(node -v)"
echo "Yarn version: $(yarn -v)"
