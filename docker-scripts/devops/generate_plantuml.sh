#!/bin/bash

# Exit on any error
set -e

# Define paths
PLANTUML_JAR="${BUILD_SOURCESDIRECTORY}/plantuml.jar"
WORKSPACE_DIR="${BUILD_SOURCESDIRECTORY}/LocalAzureAgent/Assets"
OUTPUT_DIR="${BUILD_SOURCESDIRECTORY}/attachments"
PUML_FILE="${WORKSPACE_DIR}/umbraco-models.puml"
OUTPUT_FILE="${WORKSPACE_DIR}/umbraco-models.png"

# Ensure directories exist
mkdir -p "$OUTPUT_DIR"

# Check if Java is installed
if ! command -v java &> /dev/null; then
  echo "Java is not installed. Installing Java..."
fi

# Download PlantUML JAR if not already present
if [ ! -f "$PLANTUML_JAR" ]; then
  echo "Downloading PlantUML..."
  wget -O "$PLANTUML_JAR" "https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar"
fi

# Generate PNG using PlantUML JAR
echo "Generating PNG from PlantUML script..."
java -jar "$PLANTUML_JAR" -tpng "$PUML_FILE"

# Verify if the PNG file was created
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "Error: PNG generation failed. File not found: $OUTPUT_FILE"
  exit 1
fi

# Move the PNG to the attachments directory
mv "$OUTPUT_FILE" "$OUTPUT_DIR/diagram.png"

echo "✅ PlantUML diagram successfully generated and moved to: $OUTPUT_DIR/diagram.png"
