#!/bin/bash

# Ensure the script is run from the root of the repository
echo "Starting to push diagram to the Azure DevOps Wiki..."

# Clone the Azure DevOps Wiki repository
git -c http.extraheader="AUTHORIZATION: bearer $(System.AccessToken)" clone \
  https://32302916@dev.azure.com/32302916/Local%20Azure%20Devops%20Agent/_git/Local-Azure-Devops-Agent.wiki  wiki_repo

# Create the attachments directory if it doesn't exist
mkdir -p wiki_repo/attachments

# Copy the generated diagram into the Wiki repo's attachments directory
cp $(Pipeline.Workspace)/plantuml-image/diagram.png wiki_repo/attachments/diagram.png

# Commit and push the image to the Wiki
cd wiki_repo
git add attachments/diagram.png
git commit -m "Auto-updated PlantUML diagram"
git push origin main

echo "Diagram successfully pushed to the Wiki."
