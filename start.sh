#!/bin/bash

# RL-Swarm Node Launcher
# Updated version with git clone

# Configuration
SESSION_NAME="gensyn"
PROJECT_DIR="$HOME/rl-swarm"
GIT_REPO="https://github.com/gensyn-ai/rl-swarm"
VENV_DIR="$PROJECT_DIR/.venv"
RUN_SCRIPT="$PROJECT_DIR/run_rl_swarm.sh"

# Clone repository if it doesn't exist
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Cloning repository..."
    git clone "$GIT_REPO" "$PROJECT_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone repository"
        exit 1
    fi
else
    echo "Project directory already exists, skipping clone"
fi

# Create screen session
echo "Creating screen session named '$SESSION_NAME'..."
screen -dmS $SESSION_NAME

# Send commands to the screen session
echo "Setting up the node environment in screen..."
screen -S $SESSION_NAME -X stuff "cd $PROJECT_DIR$(printf \\r)"
screen -S $SESSION_NAME -X stuff "python3 -m venv $VENV_DIR$(printf \\r)"
screen -S $SESSION_NAME -X stuff "source $VENV_DIR/bin/activate$(printf \\r)"
screen -S $SESSION_NAME -X stuff "echo 'y' | $RUN_SCRIPT$(printf \\r)"  # Automatically answers 'N' to the Hugging Face prompt

echo "Node is now running in screen session '$SESSION_NAME'!"
echo ""
echo "To attach to the session:"
echo "  screen -r $SESSION_NAME"
echo ""
echo "To detach from session (keep running in background):"
echo "  Press Ctrl+A then D"
echo ""
echo "To list all screen sessions:"
echo "  screen -ls"
