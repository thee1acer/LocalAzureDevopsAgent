#!/bin/bash

# Ensure the script is run from the root of the repository
echo "Starting to push diagram to the Azure DevOps Wiki..."

# Define environment variables for paths
OUTPUT_DIR="/home/ubuntu/agent/_work/1/s/attachments"  # Update this path if necessary
WIKI_REPO_DIR="wiki_repo"
ATTACHMENTS_DIR="${WIKI_REPO_DIR}/attachments"
IMAGE_PATH="${OUTPUT_DIR}/diagram.png"
WIKI_REPO_URL="https://32302916@dev.azure.com/32302916/Local%20Azure%20Devops%20Agent/_git/Local-Azure-Devops-Agent.wiki"

# Clone the Azure DevOps Wiki repository
echo "Cloning Wiki repository..."
git -c http.extraheader="AUTHORIZATION: bearer $(System.AccessToken)" clone $WIKI_REPO_URL $WIKI_REPO_DIR || { echo "Error cloning Wiki repo"; exit 1; }

# Create the attachments directory if it doesn't exist
echo "Creating attachments directory if it doesn't exist..."
mkdir -p "$ATTACHMENTS_DIR"

# Copy the generated diagram into the Wiki repo's attachments directory
echo "Copying diagram to Wiki repo..."
cp "$IMAGE_PATH" "$ATTACHMENTS_DIR/diagram.png" || { echo "Error copying diagram"; exit 1; }

# Commit and push the image to the Wiki
echo "Committing and pushing diagram to Wiki repository..."
cd $WIKI_REPO_DIR

# Check if there are changes to commit
if git diff --quiet; then
  echo "No changes to commit"
else
  git add attachments/diagram.png
  git commit -m "Auto-updated PlantUML diagram"
  git push origin main || { echo "Error pushing changes to Wiki"; exit 1; }
  echo "Diagram successfully pushed to the Wiki."
fi
