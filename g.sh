#!/bin/bash

# Function to display the menu
show_menu() {
    clear
    echo "===================================="
    echo "  Gensyn Node Installation Toolkit  "
    echo "===================================="
    echo "1. Install Node"
    echo "2. Start Node"
    echo "3. Check Node Status"
    echo "4. Backup Node Files"
    echo "5. Exit"
    echo "===================================="
    echo -n "Please enter your choice [1-5]: "
}

# Function to install node
install_node() {
    echo "Starting Node Installation..."
    bash <(curl -sSL https://raw.githubusercontent.com/abhiag/gensyn-ai/main/gensyn.sh)
    read -p "Press [Enter] to return to menu..."
}

# Function to start node
start_node() {
    echo "Starting Gensyn Node..."
    bash <(curl -sSL https://raw.githubusercontent.com/abhiag/gensyn-ai/main/start.sh)
    read -p "Press [Enter] to return to menu..."
}

# Function to check node status
check_status() {
    echo "Checking Node Status..."
    
    # Check if screen session exists
    if screen -list | grep -q "gensyn"; then
        echo "Detaching existing screen session..."
        screen -d -r gensyn >/dev/null 2>&1 || true
        sleep 1
        
        echo "Reattaching to screen session 'gensyn'..."
        screen -r gensyn
        
        echo "You have detached from the screen session."
    else
        echo "No 'gensyn' screen session found."
        echo "Please start your node first (Option 2)."
    fi
    
    read -p "Press [Enter] to return to menu..."
}

# Function to backup node files
backup_files() {
    echo "Backing Up Node Files..."
    
    # Check if files exist
    if [ -f "/root/rl-swarm/swarm.pem" ]; then
        # Create backup directory with timestamp
        backup_dir="gensyn_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        
        # Copy files
        cp /root/rl-swarm/swarm.pem "$backup_dir/"
        
        # Check for .pem file (assuming it might be in the same directory)
        if [ -f "/root/rl-swarm/node.pem" ]; then
            cp /root/rl-swarm/node.pem "$backup_dir/"
        fi
        
        echo "Backup completed. Files saved in: $(pwd)/$backup_dir"
    else
        echo "Error: Could not find the swarm.pem file in /root/rl-swarm/"
        echo "Please ensure your node is properly installed."
    fi
    
    read -p "Press [Enter] to return to menu..."
}

# Main menu loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) install_node ;;
        2) start_node ;;
        3) check_status ;;
        4) backup_files ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again."; sleep 2 ;;
    esac
done
