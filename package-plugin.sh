#!/bin/bash

# Package Hopkin Claude Code plugin to versioned zip file
# Usage: ./package-plugin.sh [version]
# Example: ./package-plugin.sh
# Example: ./package-plugin.sh 1.0.1

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

PLUGIN_DIR="./hopkin"

# Check if plugin directory exists
if [ ! -d "$PLUGIN_DIR" ]; then
    print_error "Plugin directory not found: $PLUGIN_DIR"
    exit 1
fi

# Check if at least one SKILL.md exists
SKILL_COUNT=$(find "$PLUGIN_DIR/skills" -name "SKILL.md" | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -eq 0 ]; then
    print_error "No SKILL.md files found in $PLUGIN_DIR/skills/"
    exit 1
fi
print_info "Found $SKILL_COUNT skill(s)"

# Determine version
if [ -n "$1" ]; then
    VERSION="$1"
    print_info "Using provided version: $VERSION"
elif [ -f "$PLUGIN_DIR/.version" ]; then
    VERSION=$(cat "$PLUGIN_DIR/.version")
    print_info "Using version from .version file: $VERSION"
else
    VERSION=$(date +"%Y%m%d-%H%M%S")
    print_warning "No version found, using timestamp: $VERSION"
fi

# Store current directory as absolute path
CURRENT_DIR=$(pwd)

# Create releases directory if it doesn't exist
RELEASES_DIR="${CURRENT_DIR}/releases"
mkdir -p "$RELEASES_DIR"

# Generate zip filename
ZIP_FILENAME="hopkin-v${VERSION}.zip"
ZIP_PATH="${RELEASES_DIR}/${ZIP_FILENAME}"

# Remove existing zip if it exists
if [ -f "$ZIP_PATH" ]; then
    print_warning "Removing existing zip: $ZIP_FILENAME"
    rm "$ZIP_PATH"
fi

print_info "Packaging plugin: hopkin"
print_info "Version: $VERSION"
print_info "Output: $ZIP_PATH"

# Create temporary directory for clean packaging
TEMP_DIR=$(mktemp -d)
TEMP_PLUGIN_DIR="$TEMP_DIR/hopkin"

# Copy plugin directory to temp location
print_info "Copying plugin files..."
cp -R "$PLUGIN_DIR" "$TEMP_PLUGIN_DIR"

# Clean up unnecessary files from temp directory
print_info "Cleaning unnecessary files..."
cd "$TEMP_PLUGIN_DIR"

rm -rf .git
rm -rf node_modules
rm -rf .DS_Store
rm -rf __pycache__
rm -rf *.pyc
rm -rf .pytest_cache
rm -rf .vscode
rm -rf .idea

cd "$CURRENT_DIR"

# Create zip file
print_info "Creating zip archive..."
cd "$TEMP_DIR"
zip -r -q "hopkin.zip" "hopkin"

# Move zip to releases directory
mv "hopkin.zip" "$ZIP_PATH"

cd "$CURRENT_DIR"

# Clean up temp directory
rm -rf "$TEMP_DIR"

# Get zip file size
FILE_SIZE=$(du -h "$ZIP_PATH" | cut -f1)

# Print success message
echo ""
print_success "Successfully packaged plugin!"
echo ""
echo "  Plugin:   hopkin"
echo "  Version:  $VERSION"
echo "  Skills:   $SKILL_COUNT"
echo "  File:     $ZIP_FILENAME"
echo "  Size:     $FILE_SIZE"
echo "  Location: $ZIP_PATH"
echo ""

# Optional: List contents of zip
if command -v unzip &> /dev/null; then
    print_info "Archive contents:"
    unzip -l "$ZIP_PATH" | head -20

    TOTAL_FILES=$(unzip -l "$ZIP_PATH" | tail -1 | awk '{print $2}')
    if [ "$TOTAL_FILES" -gt 20 ]; then
        echo "  ... and $((TOTAL_FILES - 20)) more files"
    fi
fi

echo ""
print_success "Done!"
