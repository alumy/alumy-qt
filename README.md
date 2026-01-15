# Alumy-Qt

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/alumy/alumy-qt.svg)](https://github.com/alumy/alumy-qt/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/alumy/alumy-qt.svg)](https://github.com/alumy/alumy-qt/network/members)
[![GitHub issues](https://img.shields.io/github/issues/alumy/alumy-qt.svg)](https://github.com/alumy/alumy-qt/issues)
[![GitHub release](https://img.shields.io/github/release/alumy/alumy-qt.svg)](https://github.com/alumy/alumy-qt/releases)
[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://github.com/alumy/alumy-qt)
[![Qt](https://img.shields.io/badge/Qt-5%20%7C%206-green.svg)](https://www.qt.io/)

A feature-rich SDK for rapid Qt application development, providing commonly used low-level functionality modules so developers can focus on business logic.

## Features

- **Qt5/Qt6 Compatible** - Automatic detection and adaptation for Qt versions
- **Cross-Platform** - Linux support with multiple architectures (x86_64, aarch64, ARM)
- **Modular Design** - Use only the modules you need
- **Modern CMake** - Build system supporting both shared and static libraries
- **Cross-Compilation** - Built-in toolchain configurations for various targets

## Modules

| Module | Description |
|--------|-------------|
| **CRC** | CRC16, CRC32, Modbus CRC16 checksum algorithms |
| **Audio** | WAV audio file read/write operations |
| **Network** | SLIP protocol implementation |
| **Memory** | Memory management utilities |
| **String** | String handling functions (strlcpy, etc.) |
| **CSV** | CSV file parsing (based on libcsv) |
| **Protobuf-C** | Protocol Buffers C implementation |
| **XYZModem** | YModem file transfer protocol |
| **Log** | Logging system (spdlog integration) |
| **Singleton** | Singleton pattern support |

## Requirements

- CMake >= 3.20
- Qt5 or Qt6 with the following components:
  - Widgets
  - Network
  - Core
  - SerialPort
  - Multimedia
  - Concurrent
  - PrintSupport
  - Gui
- C11 / C++11 compiler support
- Linux operating system

## Getting Started

### Build and Install

```bash
# Clone the repository
git clone --recursive https://github.com/alumy/alumy-qt.git
cd alumy-qt

# Configure for x86_64
./cmake_gen.sh --arch=x86_64

# Build
cd build-x86_64
make -j$(nproc)

# Install
sudo make install
```

### Build Script Options

The `cmake_gen.sh` script provides a convenient way to configure the build:

```bash
./cmake_gen.sh [options]
```

| Option | Description | Default |
|--------|-------------|---------|
| `--arch=ARCH` | Target architecture (x86_64, amd64, aarch64) | Required |
| `--build-type=TYPE` | Build type (Debug, Release, MinSizeRel, RelWithDebInfo) | MinSizeRel |
| `--unit-test=ON\|OFF` | Enable/disable unit tests | OFF |
| `--install-prefix=PATH` | Installation prefix path | `./release` |
| `--github-mirror=URL` | GitHub mirror URL for downloading dependencies | - |

### Cross-Compilation

Cross-compile for different architectures using the `--arch` option:

```bash
# aarch64 cross-compilation
./cmake_gen.sh --arch=aarch64
cd build-aarch64
make -j$(nproc)

# x86_64 with debug build
./cmake_gen.sh --arch=x86_64 --build-type=Debug

# Using a GitHub mirror for faster downloads
./cmake_gen.sh --arch=aarch64 --github-mirror=https://github.cache.example.com
```

### Integration

#### CMake

```cmake
find_package(alumy REQUIRED)
target_link_libraries(your_target alumy::alumy)
```

#### QMake

```qmake
include(/path/to/alumy-qt/alumy-qt.pri)
```

## Usage Examples

### Initialization

```cpp
#include <alumy.h>

int main() {
    // Initialize alumy library
    if (alumy_init() < 0) {
        // Handle error
        return -1;
    }
    
    // Your application code...
    
    // Cleanup
    alumy_cleanup();
    return 0;
}
```

### CRC Checksum

```cpp
#include <alumy/crc.h>

uint8_t data[] = {0x01, 0x02, 0x03, 0x04};

// CRC16 checksum
uint16_t crc16 = al_crc16(data, sizeof(data));

// CRC32 checksum
uint32_t crc32 = al_crc32(data, sizeof(data));

// Modbus CRC16
uint16_t mb_crc = al_mb_crc16(data, sizeof(data));
```

### WAV Audio Processing

```cpp
#include <alumy/audio/wav_file.h>

// Open WAV file
WavFile wav;
wav.open("audio.wav");

// Get audio information
int sampleRate = wav.sampleRate();
int channels = wav.channels();
```

### Logging

```cpp
#include <alumy/log.h>
#include <alumy/spdlog.h>

// Use logging macros
AL_LOG_INFO("Application started");
AL_LOG_DEBUG("Debug message: %d", value);
AL_LOG_ERROR("Error occurred: %s", error_msg);
```

### SLIP Protocol

```cpp
#include <alumy/net.h>

// SLIP encoding/decoding for serial communication
// See net/ directory for implementation details
```

## Project Structure

```
alumy-qt/
├── include/           # Header files
│   └── alumy/         # Public API headers
├── audio/             # Audio processing module
├── crc/               # CRC checksum module
├── libcsv/            # CSV parsing module
├── mem/               # Memory management module
├── net/               # Network protocol module
├── protobuf-c/        # Protocol Buffers module
├── string/            # String handling module
├── xyzmodem/          # XYZModem protocol module
├── cmake/             # CMake configuration and toolchains
│   └── toolchain/     # Cross-compilation toolchains
├── 3rd-party/         # Third-party dependencies
├── release/           # Pre-built release files
└── reentrant/         # Reentrant support (QP/C++)
```

## Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `BUILD_SHARED_LIBS` | ON | Build shared library |
| `BUILD_STATIC_LIBS` | OFF | Build static library |
| `UNIT_TEST` | OFF | Enable unit tests |

## Running Tests

```bash
./cmake_gen.sh --arch=x86_64 --unit-test=ON
cd build-x86_64
make -j$(nproc)
ctest
```

## License

This project is licensed under the [MIT License](LICENSE).

```
MIT License

Copyright (c) 2019-present jack <jackchanrs@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Author

**jack** \<jackchanrs@gmail.com\>

## Changelog

- **v0.0.1** - Initial release
