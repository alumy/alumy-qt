#!/bin/bash

TOOLCHAIN=$1
BUILD_TYPE=$2
UNIT_TEST=$3
INSTALL_PREFIX=$4

ROOTDIR=$PWD
TOOLCHAIN_DIR=$ROOTDIR/cmake/toolchain

CMAKE=$(which cmake3 2>/dev/null || which cmake2 2>/dev/null || which cmake 2>/dev/null)

if [ -x "$CMAKE" ]; then
	echo "Using cmake: $CMAKE"
else
	echo "cmake not found, please install cmake firstly"
	exit 1
fi

# enable exit on error
set -e

# Delete build directory
if [ -d build ]; then
	rm -rf build
fi

# Make build directory
mkdir build && cd build

if [ -z $INSTALL_PREFIX ]; then
	INSTALL_PREFIX=$ROOTDIR/release
fi

# add options '-LAH' if you want see all variables
$CMAKE \
	-G "Unix Makefiles" \
	-DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/$TOOLCHAIN \
	-DCMAKE_BUILD_TYPE=$BUILD_TYPE \
	-DUNIT_TEST=$UNIT_TEST \
	-DBUILD_STATIC_LIBS=ON \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
	../

exit 0
