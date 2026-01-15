#!/bin/bash
set -e

# --- Configuration ---
PROJECT_NAME="alumy-qt"
ARCHS=("x86_64" "aarch64")
RELEASE_DIR="release"

show_help() {
    echo "Usage: $0 <version_tag>"
    echo "Example: $0 v0.0.1"
    echo ""
    echo "This script will:"
    echo "1. Build the project for ${ARCHS[*]} sequentially"
    echo "2. Compile each arch using ALL available cores in parallel"
    echo "3. Create tarball packages and upload to GitHub"
}

if [ -z "$1" ]; then
    show_help
    exit 1
fi

VERSION=$1

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
echo "Creating GitHub Release $VERSION..."
echo "----------------------------------------"

gh release create "$VERSION" "${ARTIFACTS[@]}" \
    --title "$VERSION" \
    --notes "Pre-compiled binaries for $VERSION" \
    --generate-notes

echo "Successfully published $VERSION to GitHub!"
