#!/bin/bash
set -e

# --- Configuration ---
PROJECT_NAME="alumy-qt"
ARCHS=("x86_64" "aarch64")
RELEASE_DIR="release"
CMAKE_FILE="CMakeLists.txt"

# Parse version from CMakeLists.txt
parse_version() {
    local cmake_file="$1"
    
    if [ ! -f "$cmake_file" ]; then
        echo "Error: $cmake_file not found." >&2
        exit 1
    fi
    
    local major minor patch
    major=$(grep -E "^set\(PROJECT_VERSION_MAJOR\s+" "$cmake_file" | sed -E 's/.*PROJECT_VERSION_MAJOR\s+([0-9]+).*/\1/')
    minor=$(grep -E "^set\(PROJECT_VERSION_MINOR\s+" "$cmake_file" | sed -E 's/.*PROJECT_VERSION_MINOR\s+([0-9]+).*/\1/')
    patch=$(grep -E "^set\(PROJECT_VERSION_PATCH\s+" "$cmake_file" | sed -E 's/.*PROJECT_VERSION_PATCH\s+([0-9]+).*/\1/')
    
    if [ -z "$major" ] || [ -z "$minor" ] || [ -z "$patch" ]; then
        echo "Error: Failed to parse version from $cmake_file." >&2
        exit 1
    fi
    
    echo "v${major}.${minor}.${patch}"
}

# Get version from CMakeLists.txt
VERSION=$(parse_version "$CMAKE_FILE")
echo "Version from $CMAKE_FILE: $VERSION"

# Check for GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI 'gh' is not installed."
    exit 1
fi

# Clean previous release artifacts
rm -rf "$RELEASE_DIR"
rm -f *.tar.gz

# Build and Install for each architecture sequentially
ARTIFACTS=()
for ARCH in "${ARCHS[@]}"; do
    echo "========================================"
    echo "  Processing Architecture: $ARCH"
    echo "========================================"
    
    # Using the optimized cmake_gen.sh with --install which includes parallel build
    ./cmake_gen.sh --arch="$ARCH" --build-type=MinSizeRel --install --clean
    
    # Create tarball
    echo "Packaging $ARCH..."
    TARBALL="${PROJECT_NAME}-${ARCH}-${VERSION}.tar.gz"
    
    # Identify the actual architecture directory inside release/
    if [ -d "$RELEASE_DIR/$ARCH" ]; then
        PKG_ARCH_DIR="$ARCH"
    else
        echo "Error: Install failed for $ARCH. Directory $RELEASE_DIR/$ARCH not found."
        exit 1
    fi

    echo "Found architecture directory: $PKG_ARCH_DIR"
    tar -czf "$TARBALL" -C "$RELEASE_DIR" "$PKG_ARCH_DIR" "host"
    
    ARTIFACTS+=("$TARBALL")
    echo "[$ARCH] Done."
done

# Create GitHub Release
echo "----------------------------------------"
echo "Creating GitHub Release $VERSION on GitHub..."
echo "----------------------------------------"

gh release create "$VERSION" "${ARTIFACTS[@]}" \
    --repo "alumy/alumy-qt" \
    --title "$VERSION" \
    --notes "Pre-compiled binaries for $VERSION" \
    --generate-notes

echo "Successfully published $VERSION to GitHub!"
