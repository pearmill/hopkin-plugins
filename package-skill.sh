#!/bin/bash

# Package Claude Skill to versioned zip file
# Usage: ./package-skill.sh <skill-name> [version]
# Example: ./package-skill.sh meta-ads
# Example: ./package-skill.sh meta-ads 1.0.1

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

# Check if skill name is provided
if [ -z "$1" ]; then
    print_error "Usage: $0 <skill-name> [version]"
    print_info "Example: $0 meta-ads"
    print_info "Example: $0 meta-ads 1.0.1"
    exit 1
fi

SKILL_NAME="$1"
SKILL_DIR="./${SKILL_NAME}"

# Check if skill directory exists
if [ ! -d "$SKILL_DIR" ]; then
    print_error "Skill directory not found: $SKILL_DIR"
    exit 1
fi

# Check if SKILL.md exists
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
    print_error "SKILL.md not found in $SKILL_DIR"
    exit 1
fi

# Determine version
if [ -n "$2" ]; then
    # Version provided as argument
    VERSION="$2"
    print_info "Using provided version: $VERSION"
else
    # Try to extract version from SKILL.md
    VERSION=$(grep -E "^\*\*Skill Version:\*\*" "$SKILL_DIR/SKILL.md" | sed -E 's/.*Version:\*\* ([0-9.]+).*/\1/' | head -1)

    if [ -z "$VERSION" ]; then
        # Fallback to timestamp-based version
        VERSION=$(date +"%Y%m%d-%H%M%S")
        print_warning "No version found in SKILL.md, using timestamp: $VERSION"
    else
        print_info "Extracted version from SKILL.md: $VERSION"
    fi
fi

# Store current directory as absolute path
CURRENT_DIR=$(pwd)

# Create releases directory if it doesn't exist
RELEASES_DIR="${CURRENT_DIR}/releases"
mkdir -p "$RELEASES_DIR"

# Generate zip filename
ZIP_FILENAME="${SKILL_NAME}-v${VERSION}.zip"
ZIP_PATH="${RELEASES_DIR}/${ZIP_FILENAME}"

# Remove existing zip if it exists
if [ -f "$ZIP_PATH" ]; then
    print_warning "Removing existing zip: $ZIP_FILENAME"
    rm "$ZIP_PATH"
fi

print_info "Packaging skill: $SKILL_NAME"
print_info "Version: $VERSION"
print_info "Output: $ZIP_PATH"

# Create temporary directory for clean packaging
TEMP_DIR=$(mktemp -d)
TEMP_SKILL_DIR="$TEMP_DIR/$SKILL_NAME"

# Copy skill directory to temp location
print_info "Copying skill files..."
cp -R "$SKILL_DIR" "$TEMP_SKILL_DIR"

# Clean up unnecessary files from temp directory
print_info "Cleaning unnecessary files..."
cd "$TEMP_SKILL_DIR"

# Remove common unnecessary files/directories
rm -rf .git
rm -rf node_modules
rm -rf .DS_Store
rm -rf __pycache__
rm -rf *.pyc
rm -rf .pytest_cache
rm -rf .vscode
rm -rf .idea

# Return to original directory
cd "$CURRENT_DIR"

# Create zip file
print_info "Creating zip archive..."
cd "$TEMP_DIR"
zip -r -q "$SKILL_NAME.zip" "$SKILL_NAME"

# Move zip to releases directory
mv "$SKILL_NAME.zip" "$ZIP_PATH"

# Return to original directory
cd "$CURRENT_DIR"

# Clean up temp directory
rm -rf "$TEMP_DIR"

# Get zip file size
FILE_SIZE=$(du -h "$ZIP_PATH" | cut -f1)

# Print success message
echo ""
print_success "Successfully packaged skill!"
echo ""
echo "  Skill:    $SKILL_NAME"
echo "  Version:  $VERSION"
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
