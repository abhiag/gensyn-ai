#!/bin/bash

check_cuda() {
    echo "Checking CUDA installation..."
    
    # Primary check - nvcc (CUDA Toolkit)
    if command -v nvcc &>/dev/null; then
        echo -e "\033[1;32mCUDA Toolkit is installed.\033[0m"
        nvcc --version | grep "release"
        return 0
    
    # Secondary check - driver but no toolkit
    elif command -v nvidia-smi &>/dev/null && nvidia-smi | grep -q "CUDA Version"; then
        echo -e "\033[1;33mNVIDIA driver found but CUDA Toolkit (nvcc) is missing.\033[0m"
        local driver_version=$(nvidia-smi | grep -oP 'CUDA Version: \K[0-9.]+')
        echo -e "Detected Driver CUDA Version: ${driver_version}"
        
        echo -e "\033[1;36mAttempting to install matching CUDA Toolkit...\033[0m"
        if bash <(curl -sSL https://raw.githubusercontent.com/abhiag/CUDA/main/cu.sh); then
            echo -e "\033[1;32mCUDA Toolkit installed successfully!\033[0m"
            return 0
        else
            echo -e "\033[1;31mAutomatic installation failed. Try manual installation:\033[0m"
            echo -e "1. Visit: https://developer.nvidia.com/cuda-downloads"
            echo -e "2. Choose version matching your driver (${driver_version})"
            return 1
        fi
    
    # No CUDA components found
    else
        echo -e "\033[1;31mNo CUDA components found.\033[0m"
        echo -e "\033[1;33mWould you like to install CUDA? (y/n)\033[0m"
        read -r answer
        if [[ "$answer" =~ [Yy] ]]; then
            if bash <(curl -sSL https://raw.githubusercontent.com/abhiag/CUDA/main/cu.sh); then
                echo -e "\033[1;32mCUDA installed successfully!\033[0m"
                return 0
            else
                echo -e "\033[1;31mInstallation failed. Try manual installation.\033[0m"
                return 1
            fi
        else
            echo -e "\033[1;31mCUDA is required for GPU acceleration.\033[0m"
            return 1
        fi
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

# Function to handle node installation with build error fixes
install_node() {
    echo "Starting Node Installation with dependency fixes..."
    
    # First check CUDA requirements
    if ! check_cuda; then
        read -p "Press [Enter] to return to menu..."
        return 1
    fi

    # Create temporary installation directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit 1
    
    echo "Downloading and modifying installation script..."
    curl -sSL https://raw.githubusercontent.com/abhiag/gensyn-ai/main/gensyn.sh -o gensyn.sh
    
    # Apply all necessary fixes
    echo "Applying dependency fixes..."
    
    # 1. Fix protobuf conflict
    sed -i '/pip install /s/protobuf/protobuf==5.27.2/' gensyn.sh
    
    # 2. Add Next.js and Account Kit fixes
    cat << 'EOT' >> gensyn.sh
    # Additional fixes for build errors
    if [ -d "node_modules" ]; then
        echo "Applying Next.js and Account Kit fixes..."
        # Update Next.js
        npm install next@latest
        
        # Fix Account Kit dependency
        if [ -d "node_modules/@account-kit" ]; then
            cd node_modules/@account-kit/infra
            npm install viem@latest
            cd ../../..
        fi
        
        # Alternative fix if the above doesn't work
        if grep -q "'sonic' is not exported from 'viem/chains'" build.log 2>/dev/null; then
            echo "Applying sonic chain export fix..."
            npm install @account-kit/react@latest @account-kit/infra@latest
        fi
    fi
EOT

    echo "Running modified installation script..."
    bash gensyn.sh 2>&1 | tee installation.log
    
    # Check for build errors
    if grep -q "Failed to compile" installation.log || grep -q "Attempted import error" installation.log; then
        echo -e "\033[1;31mBuild error detected. Applying additional fixes...\033[0m"
        
        # Try alternative fixes
        npm install next@latest @account-kit/react@latest @account-kit/infra@latest viem@latest
        
        # If using yarn
        if command -v yarn &> /dev/null; then
            yarn add next@latest @account-kit/react@latest @account-kit/infra@latest viem@latest
        fi
    fi

    # Clean up
    cd ..
    rm -rf "$TEMP_DIR"
    
    read -p "Press [Enter] to return to menu..."
}

# Function to start node
start_node() {
    echo -e "\n\033[1;32mStarting Gensyn Node...\033[0m"
    
    # Kill any existing gensyn screen sessions
    echo "Checking for existing screen sessions..."
    screen -ls | awk '/[0-9]+\.gensyn/ {print $1}' | while read -r session; do
        echo "Terminating existing session: $session"
        screen -X -S "$session" quit
        sleep 1  # Give it a moment to terminate
    done
    
    # Verify all sessions are closed
    if screen -ls | grep -q "gensyn"; then
        echo -e "\033[1;31mFailed to terminate existing screen sessions!\033[0m"
        read -p "Press [Enter] to return to menu..."
        return 1
    fi
    
    echo "Starting new node instance..."
    if bash <(curl -sSL https://raw.githubusercontent.com/abhiag/gensyn-ai/main/start.sh); then
        echo -e "\033[1;32mNode started successfully!\033[0m"
        
        # Verify the screen session started
        sleep 2  # Wait a moment for screen to start
        if ! screen -ls | grep -q "gensyn"; then
            echo -e "\033[1;33mWarning: Node started but no screen session detected.\033[0m"
        fi
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
