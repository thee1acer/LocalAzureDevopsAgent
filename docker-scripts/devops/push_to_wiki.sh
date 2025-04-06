#!/bin/bash

set -e

echo "Starting to push diagram to code-based Azure DevOps Wiki..."

# Paths
TARGET_IMAGE="${WIKI_REPO_DIR}/umbraco-models.png"
MD_FILE="${WIKI_REPO_DIR}/Umbraco-Models-RelationShip.md"  # Replace with your desired .md file

# Ensure IMAGE_PATH is provided
if [ -z "$IMAGE_PATH" ]; then
  echo "ERROR: IMAGE_PATH is not set."
  exit 1
fi

# Copy new image over
echo "Copying image from $IMAGE_PATH to $TARGET_IMAGE"
cp "$IMAGE_PATH" "$TARGET_IMAGE" || { echo "Error copying diagram"; exit 1; }

# Debugging step: Check if the file is copied
ls -l "$TARGET_IMAGE"

# Git operations
cd "$WIKI_REPO_DIR"

git config user.email "devops-bot@mynwu.com"
git config user.name "DevOps Bot"

# Check for changes in the repository
git diff --stat

# Force add the image to track the changes
git add -f "./umbraco-models.png"

# Add the image reference to the Markdown file
echo "Adding image reference to the Markdown file: $MD_FILE"
echo -e "\n![Umbraco Models](./umbraco-models.png)" >> "$MD_FILE"

# Check if there are any changes to commit
if git diff --quiet && git diff --staged --quiet; then
  echo "No changes to commit."
else
  echo "Committing and pushing diagram to code-based Wiki..."
  git commit -m "Auto-updated PlantUML diagram and added image to README.md" --date "$(date)"
  echo "Commited"

  git remote set-url origin "https://buildagent:${TOKEN}@dev.azure.com/YOUR_ORG/YOUR_PROJECT/_git/YOUR_REPO"

  #git push origin feature/testing-local-builds || { echo "Error pushing changes"; exit 1; }
  git push origin HEAD:refs/heads/feature/testing-local-builds || { echo "Error pushing changes"; exit 1; }

  echo "Diagram and Markdown file successfully updated and pushed to the Wiki."
fi
