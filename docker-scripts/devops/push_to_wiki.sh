#!/bin/bash

set -e

echo "Starting to push diagram to code-based Azure DevOps Wiki..."

# Paths
WIKI_REPO_DIR="wiki"
ATTACHMENTS_DIR="${WIKI_REPO_DIR}/attachments"
TARGET_IMAGE="${ATTACHMENTS_DIR}/umbraco-models.png"

# Ensure IMAGE_PATH is provided
if [ -z "$IMAGE_PATH" ]; then
  echo "ERROR: IMAGE_PATH is not set."
  exit 1
fi

# Create attachments dir if it doesn't exist
mkdir -p "$ATTACHMENTS_DIR"

# Copy new image over
cp "$IMAGE_PATH" "$TARGET_IMAGE" || { echo "Error copying diagram"; exit 1; }

# Git operations
cd "$WIKI_REPO_DIR"

git config user.email "devops-bot@mynwu.com"
git config user.name "DevOps Bot"

if git diff --quiet && git diff --staged --quiet; then
  echo "No changes to commit."
else
  echo "Committing and pushing diagram to code-based Wiki..."
  git add -f "attachments/umbraco-models.png"
  git commit -m "Auto-updated PlantUML diagram"
  git push origin main || { echo "Error pushing changes"; exit 1; }
  echo "Diagram successfully pushed to the Wiki."
fi
