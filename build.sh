#!/bin/bash

# Build script for alumy-qt using CMake

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Building alumy-qt with CMake ===${NC}"

# Create build directory
BUILD_DIR="build"
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${YELLOW}Creating build directory...${NC}"
    mkdir -p "$BUILD_DIR"
fi

# Enter build directory
cd "$BUILD_DIR"

# Configure with CMake
echo -e "${YELLOW}Configuring with CMake...${NC}"
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_EXAMPLES=ON

# Build
echo -e "${YELLOW}Building...${NC}"
make -j$(nproc)

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${YELLOW}Build artifacts are in: ${BUILD_DIR}/lib${NC}"
echo -e "${YELLOW}Test executable is in: ${BUILD_DIR}/bin${NC}"

# Run test if available
if [ -f "bin/test-alumy" ]; then
    echo -e "${YELLOW}Running test executable...${NC}"
    ./bin/test-alumy
fi

cd ..
