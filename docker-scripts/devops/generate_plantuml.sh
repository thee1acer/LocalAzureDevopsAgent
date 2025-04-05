#!/bin/bash

# Exit on any error
set -e

# Define paths
PUML_FILE="${WORKSPACE_DIR}/umbraco-models.puml"
OUTPUT_FILE="${OUTPUT_DIR}/umbraco-models.png"

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
java -jar "$PLANTUML_JAR" -DPLANTUML_DOT="/usr/bin/dot" -tpng "$PUML_FILE" -o "$OUTPUT_DIR"

# Verify if the PNG file was created
if [ ! -f "${OUTPUT_FILE}" ]; then
  echo "Error: PNG generation failed. File not found: ${OUTPUT_FILE}"
  exit 1
fi

echo "PlantUML diagram successfully generated and is availablein: $OUTPUT_FILE"
