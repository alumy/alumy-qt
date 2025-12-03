#!/bin/bash
set -e

# Default values
ARCH=""
BUILD_TYPE="MinSizeRel"
UNIT_TEST="OFF"
INSTALL_PREFIX=""
CMAKE_PREFIX_PATH=""

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Architecture to toolchain mapping
declare -A TOOLCHAIN_MAP=(
	["aarch64"]="${SCRIPT_DIR}/cmake/toolchain/aarch64-linux-gnu.cmake"
	["x86_64"]="${SCRIPT_DIR}/cmake/toolchain/gcc.cmake"
	["amd64"]="${SCRIPT_DIR}/cmake/toolchain/gcc.cmake"
)

# Architecture to Qt CMAKE_PREFIX_PATH mapping
declare -A QT_PREFIX_MAP=(
	["aarch64"]="/opt/Qt5.12.12/5.12.12/aarch64"
	["x86_64"]="/opt/Qt5.12.12/5.12.12/gcc_64"
	["amd64"]="/opt/Qt5.12.12/5.12.12/gcc_64"
)

show_help() {
	cat <<-EOF
	Usage: $0 [options]
	Options:
	  --arch=ARCH              Target architecture (${!TOOLCHAIN_MAP[*]})
	  --build-type=TYPE        Build type (Debug, Release, etc.) [default: MinSizeRel]
	  --unit-test=ON|OFF       Enable/disable unit tests [default: OFF]
	  --install-prefix=PATH    Installation prefix path [default: \$SCRIPT_DIR/release]
	  -h, --help               Show this help message
	EOF
}

find_cmake() {
	local cmake_cmd
	for cmd in cmake3 cmake2 cmake; do
		cmake_cmd=$(command -v "$cmd" 2>/dev/null) && break
	done
	echo "$cmake_cmd"
}

while [[ $# -gt 0 ]]; do
	case $1 in
		--arch=*)
			ARCH="${1#*=}"
			shift
			;;
		--build-type=*)
			BUILD_TYPE="${1#*=}"
			shift
			;;
		--unit-test=*)
			UNIT_TEST="${1#*=}"
			shift
			;;
		--install-prefix=*)
			INSTALL_PREFIX="${1#*=}"
			shift
			;;
		-h|--help)
			show_help
			exit 0
			;;
		*)
			echo "Error: Unknown option: $1" >&2
			echo "Use -h or --help for usage information" >&2
			exit 1
			;;
	esac
done

# Validate required parameters
if [[ -z "$ARCH" ]]; then
	echo "Error: --arch is required" >&2
	show_help
	exit 1
fi

# Validate architecture
if [[ -z "${TOOLCHAIN_MAP[$ARCH]}" ]]; then
	echo "Error: Unknown architecture: $ARCH" >&2
	echo "Supported architectures: ${!TOOLCHAIN_MAP[*]}" >&2
	exit 1
fi

# Set CMAKE_PREFIX_PATH based on architecture
if [[ -n "${QT_PREFIX_MAP[$ARCH]}" ]]; then
	CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:+${CMAKE_PREFIX_PATH}:}${QT_PREFIX_MAP[$ARCH]}"
fi

# Find cmake
CMAKE=$(find_cmake)
if [[ ! -x "$CMAKE" ]]; then
	echo "Error: cmake not found, please install cmake first" >&2
	exit 1
fi
echo "Using cmake: $CMAKE"

# Set default install prefix
: "${INSTALL_PREFIX:=${SCRIPT_DIR}/release}"

# Prepare build directory
BUILD_DIR="${SCRIPT_DIR}/build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Run cmake
"$CMAKE" \
	-G "Unix Makefiles" \
	-DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_MAP[$ARCH]}" \
	-DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
	-DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
	-DUNIT_TEST="$UNIT_TEST" \
	-DBUILD_STATIC_LIBS=ON \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
	"$SCRIPT_DIR"
