#!/bin/bash

# Ensure the script is run from the root of the repository
echo "Starting to push diagram to the Azure DevOps Wiki..."

# Define environment variables for paths
OUTPUT_DIR="/home/ubuntu/agent/_work/1/s/attachments"  # Update this path if necessary
WIKI_REPO_DIR="wiki_repo"
ATTACHMENTS_DIR="${WIKI_REPO_DIR}/attachments"
IMAGE_PATH="${OUTPUT_DIR}/diagram.png"

# Clone the Azure DevOps Wiki repository
git -c http.extraheader="AUTHORIZATION: bearer $(System.AccessToken)" clone \
  https://32302916@dev.azure.com/32302916/Local%20Azure%20Devops%20Agent/_git/Local-Azure-Devops-Agent.wiki $WIKI_REPO_DIR

# Create the attachments directory if it doesn't exist
mkdir -p "$ATTACHMENTS_DIR"

# Copy the generated diagram into the Wiki repo's attachments directory
cp "$IMAGE_PATH" "$ATTACHMENTS_DIR/diagram.png"

# Commit and push the image to the Wiki
cd $WIKI_REPO_DIR
git add attachments/diagram.png
git commit -m "Auto-updated PlantUML diagram"
git push origin main

echo "Diagram successfully pushed to the Wiki."
