#!/bin/bash

# Exit on any error
set -e

echo "Starting to push diagram to code-based Azure DevOps Wiki..."

# Paths
WIKI_REPO_DIR="wiki"
ATTACHMENTS_DIR="${WIKI_REPO_DIR}/attachments"

# Create the attachments directory if it doesn't exist
mkdir -p "$ATTACHMENTS_DIR"

# Copy the diagram to the wiki
cp "$IMAGE_PATH" "$ATTACHMENTS_DIR/umbraco-models.png" || { echo "Error copying diagram"; exit 1; }

# Git config
git config user.email "devops-bot@mynwu.com"
git config user.name "DevOps Bot"

# Check if there are changes
if git diff --quiet && git diff --staged --quiet; then
  echo "No changes to commit."
else
  echo "Committing and pushing diagram to code-based Wiki..."
  git add "$ATTACHMENTS_DIR/umbraco-models.png"
  git commit -m "Auto-updated PlantUML diagram"
  git push origin main || { echo "Error pushing changes"; exit 1; }
  echo "Diagram successfully pushed to the Wiki."
fi
