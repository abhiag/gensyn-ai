#!/bin/bash

# RL-Swarm Node Auto-Launcher
# Creates screen session, sets up env, and runs node with auto-confirmation

# Config
SCREEN_NAME="swarm"
PROJECT_DIR="rl-swarm"
VENV_NAME=".venv"
RUN_SCRIPT="./run_rl_swarm.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}>>> Starting RL-Swarm Node Setup${NC}"

# Config
SCREEN_NAME="swarm"
PROJECT_DIR="rl-swarm"
VENV_NAME=".venv"
RUN_SCRIPT="./run_rl_swarm.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

printf "${GREEN}>>> Starting RL-Swarm Node Setup${NC}\n"

# 1. Create screen session
printf "${YELLOW}[1/3] Creating screen session '${SCREEN_NAME}'...${NC}\n"
screen -dmS $SCREEN_NAME
sleep 1

# 2. Setup virtual environment and run node
printf "${YELLOW}[2/3] Preparing node environment...${NC}\n"
screen -S $SCREEN_NAME -X stuff "cd ${PROJECT_DIR}
python3 -m venv ${VENV_NAME}
source ${VENV_NAME}/bin/activate
echo 'y' | ${RUN_SCRIPT}
$(printf '\r')"

# 3. Attach instructions
printf "${GREEN}[3/3] Node is running in screen session!${NC}\n"
printf "\nUseful commands:\n"
printf "  ${YELLOW}screen -r ${SCREEN_NAME}${NC}   - Attach to the node session\n"
printf "  ${YELLOW}screen -ls${NC}              - List all screen sessions\n"
printf "  ${YELLOW}Ctrl+A then D${NC}          - Detach from session (keep running in background)\n"

printf "\n${GREEN}Node setup complete!${NC}\n"

