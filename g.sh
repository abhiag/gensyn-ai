#!/bin/bash

# Function to check CUDA installation
check_cuda() {
    echo "Checking CUDA installation..."
    if ! command -v nvcc &> /dev/null; then
        echo -e "\n\033[1;31mCUDA is not installed or not in PATH.\033[0m"
        echo -e "\033[1;33mWould you like to install CUDA now? (y/n)\033[0m"
        read -r answer
        if [[ "$answer" =~ [Yy] ]]; then
            echo "Installing CUDA..."
            if bash <(curl -sSL https://raw.githubusercontent.com/abhiag/CUDA/main/cu.sh); then
                echo -e "\033[1;32mCUDA installed successfully!\033[0m"
                return 0
            else
                echo -e "\033[1;31mCUDA installation failed. Please install it manually.\033[0m"
                return 1
            fi
        else
            echo -e "\033[1;31mCUDA is required for Gensyn node installation.\033[0m"
            return 1
        fi
    else
        echo -e "\033[1;32mCUDA is already installed.\033[0m"
        return 0
    fi
}

# Function to display the menu
show_menu() {
    clear
    echo "===================================="
    echo "  Gensyn Node Installation Toolkit By GA-Crypto "
    echo "===================================="
    echo "1. Install Node (Check CUDA first)"
    echo "2. Start Node"
    echo "3. Check Node Status"
    echo "4. Backup Node Files"
    echo "5. Exit"
    echo "===================================="
    echo -n "Please enter your choice [1-5]: "
}

# Function to install node
install_node() {
    check_cuda || {
        read -p "Press [Enter] to return to menu..."
        return
    }
    
    echo -e "\n\033[1;32mStarting Node Installation...\033[0m"
    if bash <(curl -sSL https://raw.githubusercontent.com/abhiag/gensyn-ai/main/gensyn.sh); then
        echo -e "\033[1;32mNode installation completed successfully!\033[0m"
    else
        echo -e "\033[1;31mNode installation failed. Please check the logs.\033[0m"
    fi
    read -p "Press [Enter] to return to menu..."
}

# Function to start node
start_node() {
    echo -e "\n\033[1;32mStarting Gensyn Node...\033[0m"
    if bash <(curl -sSL https://raw.githubusercontent.com/abhiag/gensyn-ai/main/start.sh); then
        echo -e "\033[1;32mNode started successfully!\033[0m"
    else
        echo -e "\033[1;31mFailed to start node. Please check the logs.\033[0m"
    fi
    read -p "Press [Enter] to return to menu..."
}

# Function to check node status
check_status() {
    echo -e "\n\033[1;34mChecking Node Status...\033[0m"
    
    if screen -list | grep -q "gensyn"; then
        echo -e "\033[1;32mNode is running in a screen session.\033[0m"
        echo -e "\nOptions:"
        echo "1. View live logs"
        echo "2. Return to menu"
        echo -n "Choose [1-2]: "
        read -r subchoice
        
        case $subchoice in
            1)
                echo "Attaching to screen session 'gensyn' (press Ctrl+A then D to detach)..."
                screen -r gensyn
                echo "Detached from screen session."
                ;;
            2)
                return
                ;;
            *)
                echo "Invalid option."
                ;;
        esac
    else
        echo -e "\033[1;31mNo 'gensyn' screen session found.\033[0m"
        echo "Please start your node first (Option 2)."
    fi
    
    read -p "Press [Enter] to return to menu..."
}

# Function to backup node files
backup_files() {
    echo -e "\n\033[1;34mBacking Up Node Files...\033[0m"
    
    # Check if files exist
    if [ -f "/root/rl-swarm/swarm.pem" ]; then
        # Create backup directory with timestamp
        backup_dir="$HOME/gensyn_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        
        # Copy files
        echo "Backing up swarm.pem..."
        cp /root/rl-swarm/swarm.pem "$backup_dir/"
        
        # Check for other important files
        echo "Checking for additional files to backup..."
        if [ -f "/root/rl-swarm/node.pem" ]; then
            cp /root/rl-swarm/node.pem "$backup_dir/"
        fi
        
        if [ -d "/root/rl-swarm/config" ]; then
            cp -r /root/rl-swarm/config "$backup_dir/"
        fi
        
        echo -e "\033[1;32mBackup completed!\033[0m"
        echo "Files saved in: $backup_dir"
        echo -e "\nContents of backup directory:"
        ls -lh "$backup_dir"
    else
        echo -e "\033[1;31mError: Could not find the swarm.pem file in /root/rl-swarm/\033[0m"
        echo "Please ensure your node is properly installed."
    fi
    
    read -p "Press [Enter] to return to menu..."
}

# Main menu loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) install_node ;;
        2) start_node ;;
        3) check_status ;;
        4) backup_files ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo -e "\033[1;31mInvalid option. Please try again.\033[0m"; sleep 2 ;;
    esac
done
