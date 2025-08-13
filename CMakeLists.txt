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

set(QT_COMPONENTS Widgets Network Core SerialPort Multimedia Concurrent)

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

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/include
)

add_compile_definitions(AL_USE_DEFAULT_CONFIG)

link_libraries(
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Network
    Qt${QT_VERSION_MAJOR}::SerialPort
    Qt${QT_VERSION_MAJOR}::Multimedia
    Qt${QT_VERSION_MAJOR}::Concurrent
)

include_directories(
    ${Qt${QT_VERSION_MAJOR}Core_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Widgets_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Network_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}SerialPort_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Multimedia_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Concurrent_INCLUDE_DIRS}
)

add_subdirectory(3rd-party)
add_subdirectory(crc)
add_subdirectory(libcsv)  
add_subdirectory(mem)
add_subdirectory(protobuf-c)
add_subdirectory(string)
add_subdirectory(xyzmodem)
add_subdirectory(net)
add_subdirectory(audio)

set(objs
    $<TARGET_OBJECTS:crc>
    $<TARGET_OBJECTS:libcsv>
    $<TARGET_OBJECTS:mem>
    $<TARGET_OBJECTS:protobuf-c>
    $<TARGET_OBJECTS:string>
    $<TARGET_OBJECTS:xyzmodem>
    $<TARGET_OBJECTS:net>
    $<TARGET_OBJECTS:audio>
)

aux_source_directory(${PROJECT_SOURCE_DIR} ${PROJECT_NAME}_src)

include(${PROJECT_SOURCE_DIR}/cmake/check_type_size.cmake)

if(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
    if(BUILD_SHARED_LIBS)
    	message(STATUS "Building shared library for Linux")

    	add_library(${PROJECT_NAME} SHARED ${${PROJECT_NAME}_src} ${objs})
    	target_link_libraries(${PROJECT_NAME} 3rd-party)

    	add_dependencies(${PROJECT_NAME} get_git_hash)
    	add_dependencies(${PROJECT_NAME} get_svn_revision)

    	set_target_properties(${PROJECT_NAME} PROPERTIES
           	VERSION "${PROJECT_VERSION}"
           	SOVERSION "${PROJECT_VERSION_MAJOR}")

    	install(TARGETS "${PROJECT_NAME}"
            	DESTINATION "${CMAKE_INSTALL_LIBDIR}"
            	EXPORT "${PROJECT_NAME}")
    endif()
endif()

if(BUILD_STATIC_LIBS)
    add_library("${PROJECT_NAME}-static" STATIC ${${PROJECT_NAME}_src} ${objs})
    target_link_libraries("${PROJECT_NAME}-static" 3rd-party)
    
    add_dependencies("${PROJECT_NAME}-static" get_git_hash)
    add_dependencies("${PROJECT_NAME}-static" get_svn_revision)
    add_dependencies("${PROJECT_NAME}-static" 3rd-party)
    
    # target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCE_DIR})
    # target_compile_options(<target> [BEFORE] <INTERFACE|PUBLIC|PRIVATE> [items1...] [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
    
    set_target_properties("${PROJECT_NAME}-static" PROPERTIES OUTPUT_NAME "${PROJECT_NAME}")
    set_target_properties("${PROJECT_NAME}-static" PROPERTIES PREFIX "lib")
    
    install(TARGETS "${PROJECT_NAME}-static"
	    DESTINATION "${CMAKE_INSTALL_LIBDIR}")
endif()

install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/
	DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
	FILES_MATCHING PATTERN "*.h")

include(InstallRequiredSystemLibraries)
set(CPACK_PACKAGE_VENDOR alumy)
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
set(CPACK_PACKAGE_CHECKSUM "SHA256")
set(CPACK_GENERATOR "STGZ;TGZ;TZ")

set(CPACK_SOURCE_IGNORE_FILES
    ${PROJECT_SOURCE_DIR}/build
    ${PROJECT_SOURCE_DIR}/pack
    ${PROJECT_SOURCE_DIR}/.svn)
set(CPACK_SOURCE_GENERATOR "TGZ")

include(CPack)

if(UNIT_TEST EQUAL 1)
	if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
		enable_testing()
		add_subdirectory(${PROJECT_SOURCE_DIR}/test)
	endif()
endif()