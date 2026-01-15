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
    echo "1. Build the project for ${ARCHS[*]}"
    echo "2. Create tarball packages"
    echo "3. Create a GitHub Release and upload artifacts using 'gh' CLI"
}

# Check for version argument
if [ -z "$1" ]; then
    show_help
    exit 1
fi

VERSION=$1

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI 'gh' is not installed."
    echo "Please install it from https://cli.github.com/ and login using 'gh auth login'."
    exit 1
fi

# Clean up previous release directory
echo "Cleaning up $RELEASE_DIR directory..."
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# Build and Install for each architecture
for ARCH in "${ARCHS[@]}"; do
    echo "----------------------------------------"
    echo "Building for $ARCH..."
    echo "----------------------------------------"
    
    # Run the generator script
    ./cmake_gen.sh --arch="$ARCH" --build-type=MinSizeRel
    
    # Build and Install
    BUILD_DIR="build-$ARCH"
    if [ ! -d "$BUILD_DIR" ]; then
        echo "Error: Build directory $BUILD_DIR not found."
        exit 1
    fi
    
    echo "Compiling and installing $ARCH..."
    make -C "$BUILD_DIR" -j$(nproc) install
    
    # Create tarball
    echo "Packaging $ARCH..."
    TARBALL="${PROJECT_NAME}-${ARCH}-${VERSION}.tar.gz"
    
    # The install path inside 'release' is categorized by architecture
    # based on CMakeLists.txt: set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/${CMAKE_SYSTEM_PROCESSOR}")
    if [ -d "$RELEASE_DIR/$ARCH" ]; then
        tar -czvf "$TARBALL" -C "$RELEASE_DIR" "$ARCH"
    else
        # Fallback if the processor name differs (e.g., amd64 vs x86_64)
        # Search for any directory inside release/
        SUBDIR=$(ls "$RELEASE_DIR" | head -n 1)
        if [ -n "$SUBDIR" ]; then
            tar -czvf "$TARBALL" -C "$RELEASE_DIR" "$SUBDIR"
            # Move it to a standard name if needed or just use the subdir
        else
            echo "Error: Installation directory in $RELEASE_DIR not found for $ARCH."
            exit 1
        fi
    fi
    
    ARTIFACTS+=("$TARBALL")
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
