#############################################################################
# Toolchain file
#############################################################################
if(CMAKE_TOOLCHAIN_FILE)
    message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}.")
else()
    message(STATUS "No toolchain file found.")
endif()

cmake_minimum_required(VERSION 3.20)

project(alumy C CXX)

set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 0)
set(PROJECT_VERSION_PATCH 1)
set(PROJECT_VERSION_TWEAK 10)
set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")

#############################################################################
# Check for linux
#############################################################################
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolchain/toolchain-flags.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/linux_check.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/generic_check.cmake)

#############################################################################
# Parameter for compile
#############################################################################

# if(CMAKE_SIZEOF_VOID_P EQUAL 8)
#    message(STATUS "64 bits cpu")
#    set(CMAKE_INSTALL_LIBDIR lib64)
# else()
#    message(STATUS "32 bits cpu")
#    set(CMAKE_INSTALL_LIBDIR lib)
# endif()

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

set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/${CMAKE_SYSTEM_PROCESSOR}")

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/message.cmake)

find_program(CCACHE_PROGRAM ccache)

if(CCACHE_PROGRAM)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_PROGRAM})
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CCACHE_PROGRAM})
endif(CCACHE_PROGRAM)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/include/alumy/version.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/include/alumy/version.h)

#######################################################################
# get svn revision
#######################################################################
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/include/alumy/svn_revision.h
    ALL
    COMMAND ${CMAKE_COMMAND} -D TARGET_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/svn-revision.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(get_svn_revision
    ALL
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/include/alumy/svn_revision.h
)

#####################################################################
# get git hash
#####################################################################
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/include/alumy/git_hash.h
    ALL
    COMMAND ${CMAKE_COMMAND} -D TARGET_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/git-hash.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(get_git_hash
    ALL
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/include/alumy/git_hash.h
)

if(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
    link_libraries(rt)
endif()

link_libraries(m)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

#####################################################################
# Qt MOC, UI, RCC
#####################################################################
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

#####################################################################
# c & c++ standard
#####################################################################
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 11) 
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#####################################################################
# Qt Components
#####################################################################
set(QT_COMPONENTS Widgets Network Core SerialPort Multimedia Concurrent PrintSupport Gui)

find_package(QT NAMES Qt6 Qt5 COMPONENTS ${QT_COMPONENTS} REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS ${QT_COMPONENTS} REQUIRED)

find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Svg OpenGL QUIET)

if(QT_VERSION_MAJOR EQUAL 6)
    find_package(Qt${QT_VERSION_MAJOR} COMPONENTS OpenGLWidgets QUIET)
endif()

add_compile_options(-Wall)

#####################################################################
# include directories
#####################################################################
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

#####################################################################
# global definitions
#####################################################################
add_definitions(-D__STDC_FORMAT_MACROS)
add_definitions(-DAL_USE_DEFAULT_CONFIG)

#####################################################################
# compile definitions
#####################################################################

#####################################################################
# target definitions
#####################################################################
set(target_definitions AL_USE_DEFAULT_CONFIG)

#####################################################################
# link libraries
#####################################################################
link_libraries(
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Network
    Qt${QT_VERSION_MAJOR}::SerialPort
    Qt${QT_VERSION_MAJOR}::Multimedia
    Qt${QT_VERSION_MAJOR}::Concurrent
)

#####################################################################
# include directories
#####################################################################
include_directories(
    ${Qt${QT_VERSION_MAJOR}Core_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Widgets_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Network_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}SerialPort_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Multimedia_INCLUDE_DIRS}
    ${Qt${QT_VERSION_MAJOR}Concurrent_INCLUDE_DIRS}
)

#####################################################################
# subdirectories
#####################################################################
add_subdirectory(3rd-party)
add_subdirectory(crc)
add_subdirectory(libcsv)  
add_subdirectory(mem)
add_subdirectory(protobuf-c)
add_subdirectory(string)
add_subdirectory(xyzmodem)
add_subdirectory(net)
add_subdirectory(audio)

#####################################################################
# objects
#####################################################################
set(objs
    $<TARGET_OBJECTS:crc>
    $<TARGET_OBJECTS:libcsv>
    $<TARGET_OBJECTS:mem>
    $<TARGET_OBJECTS:protobuf-c>
    $<TARGET_OBJECTS:string>
    $<TARGET_OBJECTS:xyzmodem>
    $<TARGET_OBJECTS:net>
    $<TARGET_OBJECTS:audio>
    $<TARGET_OBJECTS:3rd-party>
)

#####################################################################
# sources
#####################################################################
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR} PROJECT_SOURCES)

file(GLOB_RECURSE PROJECT_HEADERS "include/*.h")

list(FILTER PROJECT_HEADERS EXCLUDE REGEX "\\.h\\.in$")

set(PROJECT_SOURCES ${PROJECT_SOURCES} ${PROJECT_HEADERS})

#####################################################################
# check type size
#####################################################################
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/check_type_size.cmake)

#####################################################################
# shared library
#####################################################################
if(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
    if(BUILD_SHARED_LIBS)
    	message(STATUS "Building shared library for Linux")

    	add_library(${PROJECT_NAME} SHARED ${PROJECT_SOURCES} ${objs})
    	    target_link_libraries(${PROJECT_NAME} 3rd-party)

    	target_include_directories(${PROJECT_NAME} PUBLIC
        	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        	$<INSTALL_INTERFACE:include>
    	)
    	
    	target_compile_definitions(${PROJECT_NAME} PUBLIC ${target_definitions})

    	add_dependencies(${PROJECT_NAME} get_git_hash)
    	add_dependencies(${PROJECT_NAME} get_svn_revision)
        add_dependencies(${PROJECT_NAME} 3rd-party)

    	set_target_properties(${PROJECT_NAME} PROPERTIES
           	VERSION "${PROJECT_VERSION}"
           	SOVERSION "${PROJECT_VERSION_MAJOR}")

    	set_target_properties(${PROJECT_NAME} PROPERTIES DEBUG_POSTFIX d)

    	install(TARGETS "${PROJECT_NAME}"
            	DESTINATION "${CMAKE_INSTALL_LIBDIR}"
            	EXPORT "${PROJECT_NAME}")
    endif()
endif()

#####################################################################
# static library
#####################################################################
if(BUILD_STATIC_LIBS)
    add_library("${PROJECT_NAME}-static" STATIC ${PROJECT_SOURCES} ${objs})
    target_link_libraries("${PROJECT_NAME}-static" 3rd-party)

    target_include_directories("${PROJECT_NAME}-static" PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    )
    
    target_compile_definitions("${PROJECT_NAME}-static" PUBLIC ${target_definitions})
    
    add_dependencies("${PROJECT_NAME}-static" get_git_hash)
    add_dependencies("${PROJECT_NAME}-static" get_svn_revision)
    add_dependencies("${PROJECT_NAME}-static" 3rd-party)
    
    set_target_properties("${PROJECT_NAME}-static" PROPERTIES OUTPUT_NAME "${PROJECT_NAME}")
    set_target_properties("${PROJECT_NAME}-static" PROPERTIES PREFIX "lib")
    set_target_properties("${PROJECT_NAME}-static" PROPERTIES DEBUG_POSTFIX d)
    
    install(TARGETS "${PROJECT_NAME}-static"
	    DESTINATION "${CMAKE_INSTALL_LIBDIR}")
endif()

#####################################################################
# alias target
#####################################################################
if(BUILD_SHARED_LIBS AND TARGET ${PROJECT_NAME})
    add_library(alumy::alumy ALIAS "${PROJECT_NAME}")
elseif(BUILD_STATIC_LIBS AND TARGET "${PROJECT_NAME}-static")
    add_library(alumy::alumy ALIAS "${PROJECT_NAME}-static")
endif()

#####################################################################
# install targets and export
#####################################################################
if(BUILD_SHARED_LIBS AND TARGET ${PROJECT_NAME})
    install(TARGETS ${PROJECT_NAME}
        EXPORT alumy-targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

if(BUILD_STATIC_LIBS AND TARGET "${PROJECT_NAME}-static")
    set_target_properties("${PROJECT_NAME}-static" PROPERTIES EXPORT_NAME "alumy")

    install(TARGETS "${PROJECT_NAME}-static"
        EXPORT alumy-targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

# Install project headers only from the main project directory
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        FILES_MATCHING PATTERN "*.h")
endif()

install(EXPORT alumy-targets
    FILE alumy-targets.cmake
    NAMESPACE alumy::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/alumy)

include(CMakePackageConfigHelpers)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/alumy-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/alumy-config.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/alumy
    PATH_VARS CMAKE_INSTALL_INCLUDEDIR CMAKE_INSTALL_LIBDIR
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/alumy-config-version.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/alumy-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/alumy-config-version.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/alumy)

include(InstallRequiredSystemLibraries)
set(CPACK_PACKAGE_VENDOR alumy)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
set(CPACK_PACKAGE_CHECKSUM "SHA256")
set(CPACK_GENERATOR "STGZ;TGZ;TZ")

set(CPACK_SOURCE_IGNORE_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/build
    ${CMAKE_CURRENT_SOURCE_DIR}/pack
    ${CMAKE_CURRENT_SOURCE_DIR}/.svn)
set(CPACK_SOURCE_GENERATOR "TGZ")

include(CPack)

#####################################################################
# unit test
#####################################################################
if(UNIT_TEST EQUAL 1)
	if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
		enable_testing()
		add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/test)
	endif()
endif()
