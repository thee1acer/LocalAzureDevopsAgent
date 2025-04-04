#!/bin/bash

# Install dependencies as root
apt-get update && apt-get install -y curl tar libicu-dev expect git iputils-ping

if ! command -v docker &>/dev/null; then
    echo "### Docker not found. Installing Docker... ###"

    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    echo "### Docker installed successfully. ###"
else
    echo "Docker is already installed."
fi

# Add the ubuntu user to the docker group so it can access Docker without root
usermod -aG docker ubuntu

# Check if Docker is installed on the host and if not, notify
DOCKER_SOCKET="/var/run/docker.sock"

if [ ! -S "$DOCKER_SOCKET" ]; then
    echo "### Docker socket not found. Attempting to mount it. ###"
    # Try to mount the Docker socket dynamically if not found
    if [ -f "/etc/docker/daemon.json" ] && grep -q '"hosts":' "/etc/docker/daemon.json"; then
        echo "### Docker socket might be configured in daemon.json. Trying to mount it. ###"
        mount --bind /var/run/docker.sock /var/run/docker.sock
    else
        echo "### Docker socket is still not found. Exiting. ###"
        exit 1
    fi
else
    echo "### Docker socket found. ###"
fi

# Set the working directory
AGENT_DIR="/home/ubuntu/agent"
mkdir -p "$AGENT_DIR"
chown -R ubuntu:ubuntu "$AGENT_DIR"

# Ensure the "ubuntu" user exists
if ! id "ubuntu" >/dev/null 2>&1; then
    echo "### Error: User 'ubuntu' does not exist! ###"
    exit 1
fi

# Switch to the "ubuntu" user and install or update the agent
# See this link for updated versions of the agent: https://github.com/microsoft/azure-pipelines-agent/releases
su - ubuntu -c "bash -c '
    set -e
    AGENT_VERSION=\"4.255.0\"  # Update if necessary
    AGENT_URL=\"https://vstsagentpackage.azureedge.net/agent/\$AGENT_VERSION/vsts-agent-linux-x64-\$AGENT_VERSION.tar.gz\"
    AGENT_DIR=\"\$HOME/agent\"

    echo \"### Checking out agent dir ###\"
    ls -a \"$AGENT_DIR\"

    if [ -f \"\$AGENT_DIR/.agent\" ]; then
        echo \"### Agent already exists. Checking if it needs an update... ###\"
    fi

    if [ ! -f \"\$AGENT_DIR/.agent\" ]; then
        if [ -f \"\$AGENT_DIR/vsts-agent-\$AGENT_VERSION.tar.gz\" ] && gzip -t \"\$AGENT_DIR/vsts-agent-\$AGENT_VERSION.tar.gz\" && ls -lh \"\$AGENT_DIR/vsts-agent-\$AGENT_VERSION.tar.gz\"; then
            echo \"### Existing tar file found. Now extracting... ###\"
        else
            echo \"### Agent not found and no existing tar file. Starting download... ###\"
            curl -L \$AGENT_URL -o \$AGENT_DIR/vsts-agent-\$AGENT_VERSION.tar.gz
        fi

        tar zxvf \$AGENT_DIR/vsts-agent-\$AGENT_VERSION.tar.gz -C \$AGENT_DIR --strip-components=1
        echo \"### Done downloading and extracting agent. ###\"
    fi

    cd \$AGENT_DIR
    chmod +x config.sh

    echo \"### Connecting to the agent pool ###\"
    ./config.sh --url \"${AZURE_COMPANY_URL}\" --auth PAT --token \"${AZURE_PERSONAL_TOKEN}\" --pool \"${AZURE_AGENT_POOL}\" --agent \"ubuntu-agent-\$(hostname)\"
    echo \"### Connecting to the agent pool is complete ###\"
'"

# Ensure we are in the correct directory before running the agent
if [ -f "$AGENT_DIR/run.sh" ]; then
    chmod +x "$AGENT_DIR/run.sh"
    cd "$AGENT_DIR" || { echo "### Failed to change directory to agent root! ###"; exit 1; }
    echo "### Starting Azure DevOps Agent in foreground as ubuntu... ###"
    
    # Set the environment variable to disable downgrades
    export AZP_AGENT_DOWNGRADE_DISABLED=true

    # Run the agent as the 'ubuntu' user, allowing Docker to function properly
    exec su - ubuntu -c "$AGENT_DIR/run.sh"
    
else
    echo "### Error: run.sh not found! Unable to start the agent. ###"
    exit 1
fi
