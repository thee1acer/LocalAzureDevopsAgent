#!/bin/bash

# Check if Docker is available
if ! command -v docker &> /dev/null; then
  echo "Docker is not available. Attempting to install Docker..."

  # Example installation for Ubuntu-based systems
  sudo apt-get update -y && sudo apt-get install -y docker.io

  # Verify installation
  if ! command -v docker &> /dev/null; then
    echo "Error: Docker installation failed. Please install Docker manually."
    exit 1
  fi
fi

echo "Docker is available: $(docker --version)"

# Create the attachments directory
mkdir -p "${BUILD_SOURCESDIRECTORY}/attachments"

# Run the PlantUML Docker command to generate the PNG image
docker run --rm -v "${BUILD_SOURCESDIRECTORY}/Local Azure Agent/Assets:/workspace" plantuml/plantuml -tpng /workspace/umbraco-models.puml

# Verify if the PNG was generated successfully
if [ ! -f "${BUILD_SOURCESDIRECTORY}/Local Azure Agent/Assets/umbraco-models.png" ]; then
  echo "Error: PNG generation failed. The file umbraco-models.png was not found."
  exit 1
fi

# Move the generated PNG to the attachments directory
mv "${BUILD_SOURCESDIRECTORY}/Local Azure Agent/Assets/umbraco-models.png" "${BUILD_SOURCESDIRECTORY}/attachments/diagram.png"

echo "PlantUML diagram generated and moved successfully to the attachments directory."
