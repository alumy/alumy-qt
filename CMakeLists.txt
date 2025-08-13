#############################################################################
# Toolchain file
#############################################################################
message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}.")

cmake_minimum_required(VERSION 3.10)
project(alumy-qt C CXX)

set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 0)
set(PROJECT_VERSION_PATCH 1)
set(PROJECT_VERSION_TWEAK 10)
set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")

#############################################################################
# Check for linux
#############################################################################
include(${PROJECT_SOURCE_DIR}/cmake/toolchain/toolchain-flags.cmake)
include(${PROJECT_SOURCE_DIR}/cmake/linux_check.cmake)
include(${PROJECT_SOURCE_DIR}/cmake/generic_check.cmake)

#############################################################################
# Parameter for compile
#############################################################################

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(STATUS "64 bits cpu")
    set(CMAKE_INSTALL_LIBDIR lib64)
else()
    message(STATUS "32 bits cpu")
    set(CMAKE_INSTALL_LIBDIR lib)
endif()

#############################################################################
# Options
#############################################################################
option(BUILD_SHARED_LIBS "enable shared library" OFF)
option(BUILD_STATIC_LIBS "enable shared library" ON)

if(BUILD_STATIC_LIBS)
	set(BUILD_SHARED_LIBS OFF)
endif()

if(UNIT_TEST EQUAL 1)
	add_definitions(-DAL_UT)
endif()

include(GNUInstallDirs)
include(${PROJECT_SOURCE_DIR}/cmake/message.cmake)

find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
endif(CCACHE_FOUND)

configure_file(
    ${PROJECT_SOURCE_DIR}/include/alumy/version.h.in
    ${PROJECT_SOURCE_DIR}/include/alumy/version.h)

#######################################################################
# get svn revision
#######################################################################
add_custom_command(
    OUTPUT ${PROJECT_SOURCE_DIR}/include/alumy/svn_revision.h
    ALL
    COMMAND ${CMAKE_COMMAND} -D TARGET_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_SOURCE_DIR}/cmake/svn-revision.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# rebuild svn_revision.h every time
add_custom_target(get_svn_revision
    ALL
    DEPENDS ${PROJECT_SOURCE_DIR}/include/alumy/svn_revision.h
)

#####################################################################
# get git hash
#####################################################################
add_custom_command(
    OUTPUT ${PROJECT_SOURCE_DIR}/include/alumy/git_hash.h
    ALL
    COMMAND ${CMAKE_COMMAND} -D TARGET_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${PROJECT_SOURCE_DIR}/cmake/git-hash.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# rebuild git_hash.h every time
add_custom_target(get_git_hash
    ALL
    DEPENDS ${PROJECT_SOURCE_DIR}/include/alumy/git_hash.h
)

add_definitions(-D__STDC_FORMAT_MACROS)
add_definitions(-DAL_USE_DEFAULT_CONFIG)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

if(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
    link_libraries(rt)
endif()

link_libraries(m)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14) 
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QT_COMPONENTS Widgets Network Core SerialPort Multimedia)

find_package(QT NAMES Qt6 Qt5 COMPONENTS ${QT_COMPONENTS} REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS ${QT_COMPONENTS} REQUIRED)

# Build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

# Compiler options  
add_compile_options(-Wall)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-g -O0)
else()
    add_compile_options(-O3 -DNDEBUG)
endif()

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/3rd-party
)

add_compile_definitions(AL_USE_DEFAULT_CONFIG)

link_libraries(
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Network
    Qt${QT_VERSION_MAJOR}::SerialPort
    Qt${QT_VERSION_MAJOR}::Multimedia
)

include_directories(
    ${Qt${QT_VERSION_MAJOR}Core_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Widgets_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Network_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}SerialPort_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Multimedia_INCLUDE_DIRS}
)

add_subdirectory(crc)
add_subdirectory(libcsv)  
add_subdirectory(mem)
add_subdirectory(protobuf-c)
add_subdirectory(string)
add_subdirectory(xyzmodem)
add_subdirectory(net)
add_subdirectory(audio)

set(PROJECT_SOURCES
        version.c
        log.c
        ascii.c
)

set(PROJECT_OBJS
    $<TARGET_OBJECTS:crc>
    $<TARGET_OBJECTS:libcsv>
    $<TARGET_OBJECTS:mem>
    $<TARGET_OBJECTS:protobuf-c>
    $<TARGET_OBJECTS:string>
    $<TARGET_OBJECTS:xyzmodem>
    $<TARGET_OBJECTS:net>
    $<TARGET_OBJECTS:audio>
)

# Create main library from object libraries
add_library(${PROJECT_NAME} STATIC
    ${PROJECT_SOURCES}
    ${PROJECT_OBJS}
)

# Set library properties
set_target_properties(${PROJECT_NAME} PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    OUTPUT_NAME alumy-qt
)

# Create shared library option
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
if(BUILD_SHARED_LIBS)
    add_library(${PROJECT_NAME}-shared SHARED
        ${PROJECT_SOURCES}
        ${PROJECT_OBJS}
    )

    set_target_properties(${PROJECT_NAME}-shared PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION_MAJOR}
        OUTPUT_NAME alumy-qt
    )
endif()

# Testing support
option(BUILD_TESTING "Build test programs" OFF)
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(test)
endif()

# Example programs
option(BUILD_EXAMPLES "Build example programs" ON)
if(BUILD_EXAMPLES)
    # Simple test program
    add_executable(test-alumy
        version.c
        log.c
        ascii.c
    )
    target_link_libraries(test-alumy ${PROJECT_NAME})
    target_include_directories(test-alumy PRIVATE ${CMAKE_SOURCE_DIR}/include)
endif()

# Install rules
install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}-targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

if(BUILD_SHARED_LIBS)
    install(TARGETS ${PROJECT_NAME}-shared
        EXPORT ${PROJECT_NAME}-targets
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin
    )
endif()

# Install headers
install(DIRECTORY include/ DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)

# Package configuration
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

# Export targets
export(TARGETS ${PROJECT_NAME} 
    FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-targets.cmake"
    NAMESPACE ${PROJECT_NAME}::
)

# Create config file  
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/${PROJECT_NAME}-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
    @ONLY
)

# Install config files
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
    DESTINATION lib/cmake/${PROJECT_NAME}
)

install(EXPORT ${PROJECT_NAME}-targets
    FILE ${PROJECT_NAME}-targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION lib/cmake/${PROJECT_NAME}
)

# Print configuration summary
message(STATUS "Configuration Summary:")
message(STATUS "  Project: ${PROJECT_NAME} ${PROJECT_VERSION}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  C++ compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "  Build shared libs: ${BUILD_SHARED_LIBS}")
message(STATUS "  Build examples: ${BUILD_EXAMPLES}")
message(STATUS "  Build testing: ${BUILD_TESTING}")
