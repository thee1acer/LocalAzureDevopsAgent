#!/bin/bash
set -e  # Exit on any error

# Install dependencies as root
apt-get update && apt-get install -y curl tar libicu-dev expect git

# Ensure the "ubuntu" user exists
if ! id "ubuntu" >/dev/null 2>&1; then
    echo "Error: User 'ubuntu' does not exist! 😭😿💔"
    exit 1
fi

# Set the working directory
AGENT_DIR="/home/ubuntu/agent"
mkdir -p "$AGENT_DIR"
chown -R ubuntu:ubuntu "$AGENT_DIR"

# Switch to ubuntu user and install agent
su - ubuntu -c "bash -c '
    set -e
    AGENT_VERSION=\"4.254.0\"
    AGENT_URL=\"https://vstsagentpackage.azureedge.net/agent/\$AGENT_VERSION/vsts-agent-linux-x64-\$AGENT_VERSION.tar.gz\"
    AGENT_DIR=\"\$HOME/agent\"

    # Check if agent is already installed
    if [ -f \"\$AGENT_DIR/.agent\" ]; then
        echo \"Agent already exists. Checking if it needs an update... 🧐\"

        # Extract the current version safely
        CURRENT_VERSION=\$(grep -oP \"(?<=Agent.Version=)[0-9\.]+\" \$AGENT_DIR/.agent || echo \"0\")

        if [ \"\$CURRENT_VERSION\" == \"\$AGENT_VERSION\" ]; then
            echo \"Agent is already at the latest version (\$CURRENT_VERSION). Skipping installation. 🚀\"
        else
            echo \"Updating agent from version \$CURRENT_VERSION to \$AGENT_VERSION... 🔄\"
            rm -rf \$AGENT_DIR
            mkdir -p \$AGENT_DIR
        fi
    else
        echo \"No existing agent found. Proceeding with installation... 🔧\"
    fi

    # If the directory was removed (update case) or didn’t exist, install the agent
    if [ ! -f \"\$AGENT_DIR/.agent\" ]; then
        echo \"Started downloading agent 🛒🔃\"
        curl -L \$AGENT_URL -o \$AGENT_DIR/vsts-agent.tar.gz
        tar zxvf \$AGENT_DIR/vsts-agent.tar.gz -C \$AGENT_DIR --strip-components=1
        echo \"Done downloading agent 🛒🥳✅\"
    fi
    
    cd \$AGENT_DIR
    chmod +x config.sh
    
    echo \"Connecting to the agent pool 👨‍💻🔃\"
    ./config.sh --url \"${AZURE_COMPANY_URL}\" --auth PAT --token \"${AZURE_PERSONAL_TOKEN}\" --pool \"${AZURE_AGENT_POOL}\" --agent \"ubuntu-agent-\$(hostname)\"
    echo \"Connecting to the agent pool is complete 👨‍💻🥳✅\"
'"

# Instead of using systemd, run the agent in the foreground as the "ubuntu" user
AGENT_DIR="/home/ubuntu/agent"

# Ensure we are in the correct directory before running the agent
if [ -f "$AGENT_DIR/run.sh" ]; then
    chmod +x "$AGENT_DIR/run.sh"
    cd "$AGENT_DIR" || { echo "Failed to change directory to agent root!"; exit 1; }
    echo "Starting Azure DevOps Agent in foreground as ubuntu... 🚀"
    
    # Switch to the 'ubuntu' user and run the agent
    exec su - ubuntu -c "$AGENT_DIR/run.sh"
else
    echo "Error: run.sh not found! Unable to start the agent. ❌"
    exit 1
fi