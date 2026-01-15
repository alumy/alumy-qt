# Alumy-Qt

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/alumy/alumy-qt.svg)](https://github.com/alumy/alumy-qt/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/alumy/alumy-qt.svg)](https://github.com/alumy/alumy-qt/issues)
[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://github.com/alumy/alumy-qt)
[![Qt](https://img.shields.io/badge/Qt-5%20%7C%206-green.svg)](https://www.qt.io/)

A feature-rich SDK for rapid Qt application development, providing commonly used low-level functionality modules so developers can focus on business logic.

## Features

- Qt5/Qt6 compatible
- Multi-architecture support (x86_64, aarch64, ARM)
- Modular design
- Modern CMake build system
- Cross-compilation ready

## Modules

| Module | Description |
|--------|-------------|
| CRC | CRC16, CRC32, Modbus CRC16 checksum algorithms |
| Audio | WAV audio file read/write operations |
| Network | SLIP protocol implementation |
| Memory | Memory management utilities |
| String | String handling functions |
| CSV | CSV file parsing (libcsv) |
| Protobuf-C | Protocol Buffers C implementation |
| XYZModem | YModem file transfer protocol |
| Log | Logging system (spdlog) |

## Requirements

- CMake >= 3.20
- Qt5 or Qt6
- C11/C++11 compiler
- Linux

## Quick Start

```bash
git clone --recursive https://github.com/alumy/alumy-qt.git
cd alumy-qt

./cmake_gen.sh --arch=x86_64
cd build-x86_64
make -j$(nproc)
sudo make install
```

## Usage

```cpp
#include <alumy.h>

int main() {
    alumy_init();
    // Your code here
    alumy_cleanup();
    return 0;
}
```

**CMake integration:**

```cmake
find_package(alumy REQUIRED)
target_link_libraries(your_target alumy::alumy)
```

## Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `--arch` | Required | Target architecture (x86_64, aarch64) |
| `--build-type` | MinSizeRel | Build type (Debug, Release) |
| `--unit-test` | OFF | Enable unit tests |
| `--install-prefix` | ./release | Installation path |

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

[MIT License](LICENSE)

## Author

jack <jackchanrs@gmail.com>

## Links

- [Changelog](CHANGELOG.md)
- [Releases](https://github.com/alumy/alumy-qt/releases)
- [Issues](https://github.com/alumy/alumy-qt/issues)
