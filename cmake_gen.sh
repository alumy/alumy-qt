#!/bin/bash
set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
ARCH=""
BUILD_TYPE="MinSizeRel"
UNIT_TEST="OFF"
INSTALL_PREFIX="${SCRIPT_DIR}/release"
GITHUB_MIRROR="${GITHUB_MIRROR:-}"
DO_BUILD=false
DO_INSTALL=false
CLEAN=false

# Architecture mapping
declare -A TOOLCHAIN_MAP=(
	["aarch64"]="${SCRIPT_DIR}/cmake/toolchain/aarch64-linux-gnu.cmake"
	["x86_64"]="${SCRIPT_DIR}/cmake/toolchain/gcc.cmake"
	["amd64"]="${SCRIPT_DIR}/cmake/toolchain/gcc.cmake"
)

# Qt prefix mapping
declare -A QT_PREFIX_MAP=(
	["aarch64"]="/opt/Qt5.12.12/5.12.12/t507_aarch64"
	["x86_64"]="/opt/Qt5.12.12/5.12.12/gcc_64"
	["amd64"]="/opt/Qt5.12.12/5.12.12/gcc_64"
)

# Qt5_DIR mapping
declare -A QT5_DIR_MAP=(
	["aarch64"]="/opt/Qt5.12.12/5.12.12/t507_aarch64/lib/cmake/Qt5"
	["x86_64"]="/opt/Qt5.12.12/5.12.12/gcc_64/lib/cmake/Qt5"
	["amd64"]="/opt/Qt5.12.12/5.12.12/gcc_64/lib/cmake/Qt5"
)

# Sysroot mapping
declare -A SYSROOT_MAP=(
	["aarch64"]="/opt/t507-aarch64-linux-gnu/aarch64-buildroot-linux-gnu/sysroot/"
	["x86_64"]=""
	["amd64"]=""
)

show_help() {
	cat <<-EOF
	Usage: $0 --arch=ARCH [options]
	Options:
	  --arch=ARCH              Target architecture (${!TOOLCHAIN_MAP[*]})
	  --build-type=TYPE        Build type (Debug, Release, MinSizeRel) [default: MinSizeRel]
	  --unit-test=ON|OFF       Enable unit tests [default: OFF]
	  --install-prefix=PATH    Custom install path [default: \$SCRIPT_DIR/release]
	  --github-mirror=URL      GitHub mirror URL
	  --build                  Execute build after configuration
	  --install                Execute install after build
	  --clean                  Remove build directory before configuring
	  -h, --help               Show this help
	EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		--arch=*) ARCH="${1#*=}"; shift ;;
		--build-type=*) BUILD_TYPE="${1#*=}"; shift ;;
		--unit-test=*) UNIT_TEST="${1#*=}"; shift ;;
		--install-prefix=*) INSTALL_PREFIX="${1#*=}"; shift ;;
		--github-mirror=*) GITHUB_MIRROR="${1#*=}"; shift ;;
		--build) DO_BUILD=true; shift ;;
		--install) DO_INSTALL=true; DO_BUILD=true; shift ;;
		--clean) CLEAN=true; shift ;;
		-h|--help) show_help; exit 0 ;;
		*) echo "Error: Unknown option: $1"; exit 1 ;;
	esac
done

if [[ -z "$ARCH" || -z "${TOOLCHAIN_MAP[$ARCH]}" ]]; then
	echo "Error: Valid --arch is required (${!TOOLCHAIN_MAP[*]})"
	show_help
	exit 1
fi

# Prepare Build Directory
BUILD_DIR="${SCRIPT_DIR}/build-$ARCH"
if [[ "$CLEAN" == "true" ]]; then
	echo ">>> Cleaning build directory: $BUILD_DIR"
	rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"

# Set CMake arguments
CMAKE_ARGS=(
	-S "$SCRIPT_DIR"
	-B "$BUILD_DIR"
	-G "Unix Makefiles"
	-DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_MAP[$ARCH]}"
	-DCMAKE_PREFIX_PATH="${QT_PREFIX_MAP[$ARCH]}"
	-DCMAKE_FIND_ROOT_PATH="${SYSROOT_MAP[$ARCH]};${QT_PREFIX_MAP[$ARCH]}"
	-DQt5_DIR="${QT5_DIR_MAP[$ARCH]}"
	-DCMAKE_BUILD_TYPE="$BUILD_TYPE"
	-DUNIT_TEST="$UNIT_TEST"
	-DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
)

if [[ -n "${SYSROOT_MAP[$ARCH]}" ]]; then
	CMAKE_ARGS+=(-DCMAKE_SYSROOT="${SYSROOT_MAP[$ARCH]}")
fi

if [[ -n "$GITHUB_MIRROR" ]]; then
	export GITHUB_MIRROR
fi

# Configure
echo ">>> Configuring for $ARCH..."
cmake "${CMAKE_ARGS[@]}"

# Build
if [[ "$DO_BUILD" == "true" ]]; then
	NPROC=$(nproc)
	echo ">>> Building $ARCH with $NPROC jobs..."
	cmake --build "$BUILD_DIR" -j "$NPROC"
fi

# Install
if [[ "$DO_INSTALL" == "true" ]]; then
	echo ">>> Installing $ARCH to $INSTALL_PREFIX..."
	cmake --install "$BUILD_DIR"
fi

echo ">>> Done ($ARCH)."
