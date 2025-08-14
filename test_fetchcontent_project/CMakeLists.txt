cmake_minimum_required(VERSION 3.10)
project(test_fetchcontent)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include FetchContent
include(FetchContent)

# Declare and fetch alumy library
FetchContent_Declare(
    alumy
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Set build options for alumy
set(BUILD_STATIC_LIBS ON CACHE BOOL "Build static library" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared library" FORCE)

FetchContent_MakeAvailable(alumy)

# Find Qt (similar to how alumy does it)
set(QT_COMPONENTS Widgets Network Core SerialPort Multimedia Concurrent)
find_package(QT NAMES Qt6 Qt5 COMPONENTS ${QT_COMPONENTS} REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS ${QT_COMPONENTS} REQUIRED)

add_definitions(-DAL_USE_DEFAULT_CONFIG)

# Create test executable
add_executable(test_fetchcontent main.cpp)

# Link against alumy
target_link_libraries(test_fetchcontent 
    alumy::alumy
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Widgets
)

# Add include directories for Qt
target_include_directories(test_fetchcontent PRIVATE
    ${Qt${QT_VERSION_MAJOR}Core_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Widgets_INCLUDE_DIRS}
)
