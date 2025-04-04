#!/bin/bash

# Exit on any error
set -e

# Ensure the script is run from the root of the repository
echo "Starting to push diagram to the Azure DevOps Wiki..."

# Define environment variables for paths
OUTPUT_DIR="/home/ubuntu/agent/_work/1/s/attachments"  # Update this path if necessary
WIKI_REPO_DIR="wiki_repo"
ATTACHMENTS_DIR="${WIKI_REPO_DIR}/attachments"
IMAGE_PATH="${OUTPUT_DIR}/umbraco-models.png"

# Ensure SYSTEM_ACCESSTOKEN is available
if [ -z "$SYSTEM_ACCESSTOKEN" ]; then
  echo "Error: SYSTEM_ACCESSTOKEN is not set."
  exit 1
fi

# Ensure WIKI_REPO_URL is available
if [ -z "$WIKI_REPO_URL" ]; then
  echo "Error: WIKI_REPO_URL is not set."
  exit 1
fi


# Clone the Azure DevOps Wiki repository
echo "Cloning Wiki repository..."
git clone "https://oauth2:$SYSTEM_ACCESSTOKEN@$WIKI_REPO_URL" "$WIKI_REPO_DIR" || { echo "Error cloning Wiki repo"; exit 1; }

# Create the attachments directory if it doesn't exist
echo "Creating attachments directory if it doesn't exist..."
mkdir -p "$ATTACHMENTS_DIR"

# Copy the generated diagram into the Wiki repo's attachments directory
echo "Copying diagram to Wiki repo..."
cp "$IMAGE_PATH" "$ATTACHMENTS_DIR/diagram.png" || { echo "Error copying diagram"; exit 1; }

# Commit and push the image to the Wiki
cd "$WIKI_REPO_DIR"

# Configure git user (to avoid commit failures)
git config user.email "devops-bot@mynwu.com"
git config user.name "DevOps Bot"

# Check if there are changes to commit
if git diff --quiet && git diff --staged --quiet; then
  echo "No changes to commit."
else
  echo "Committing and pushing diagram to Wiki repository..."
  git add attachments/diagram.png
  git commit -m "Auto-updated PlantUML diagram"
  git push origin main || { echo "Error pushing changes to Wiki"; exit 1; }
  echo "Diagram successfully pushed to the Wiki."
fi
