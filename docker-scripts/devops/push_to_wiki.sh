#!/bin/bash

set -e

# Logging with timestamps
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting to push diagram to code-based Azure DevOps Wiki..."

# Paths
TARGET_IMAGE="${WIKI_REPO_DIR}/umbraco-models.png"
MD_FILE="${WIKI_REPO_DIR}/Umbraco-Models-RelationShip.md"
IMAGE_REF="![Umbraco Models](./umbraco-models.png)"

# Ensure IMAGE_PATH is provided
if [ -z "$IMAGE_PATH" ]; then
  log "ERROR: IMAGE_PATH is not set."
  exit 1
fi

# Copy new image over
log "Copying image from $IMAGE_PATH to $TARGET_IMAGE"
cp "$IMAGE_PATH" "$TARGET_IMAGE" || { log "Error copying diagram"; exit 1; }

# Debugging step: Check if the file is copied
ls -l "$TARGET_IMAGE"

# Git operations
cd "$WIKI_REPO_DIR"

git config user.email "devops-bot@mynwu.com"
git config user.name "DevOps Bot"

# Warn if in detached HEAD state
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" = "HEAD" ]; then
  log "WARNING: You are in a detached HEAD state."
fi

# Check for changes in the repository
git diff --stat

# Force add the image to track the changes
git add -f "./umbraco-models.png"

# Add the image reference to the Markdown file if not already present
if ! grep -Fxq "$IMAGE_REF" "$MD_FILE"; then
  log "Adding image reference to the Markdown file: $MD_FILE"
  echo -e "\n$IMAGE_REF" >> "$MD_FILE"
  git add "$MD_FILE"
else
  log "Image reference already exists in Markdown file."
fi

# Check if there are any changes to commit
if git diff --quiet && git diff --staged --quiet; then
  log "No changes to commit."
else
  log "Committing and pushing diagram to code-based Wiki..."
  git commit -m "Auto-updated PlantUML diagram and added image to README.md" --date "$(date)"
  log "Committed changes."

  git remote set-url origin "https://buildagent:$TOKEN@$HOST_ADDRESS" || { log "Error setting URL"; exit 1; }
  git push origin "$CURRENT_BRANCH" || { log "Error pushing changes"; exit 1; }

  log "Diagram and Markdown file successfully updated and pushed to the Wiki."
fi
