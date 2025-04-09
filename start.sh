#!/bin/bash

# RL-Swarm Node Launcher
# Fully working version

# Configuration
SESSION_NAME="gensyn"
PROJECT_DIR="$HOME/rl-swarm"
VENV_DIR="$PROJECT_DIR/.venv"
RUN_SCRIPT="$PROJECT_DIR/run_rl_swarm.sh"

# Create screen session
echo "Creating screen session named '$SESSION_NAME'..."
screen -dmS $SESSION_NAME

# Send commands to the screen session
echo "Setting up the node environment in screen..."
screen -S $SESSION_NAME -X stuff "cd $PROJECT_DIR$(printf \\r)"
screen -S $SESSION_NAME -X stuff "python3 -m venv $VENV_DIR$(printf \\r)"
screen -S $SESSION_NAME -X stuff "source $VENV_DIR/bin/activate$(printf \\r)"
screen -S $SESSION_NAME -X stuff "y | $RUN_SCRIPT$(printf \\r)"

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
