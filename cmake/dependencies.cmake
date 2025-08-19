include(FetchContent)
include(ExternalProject)

macro(configure_alumy_dependencies)
    if(NOT TARGET spdlog::spdlog)
        FetchContent_Declare(
            spdlog
            GIT_REPOSITORY https://github.com/gabime/spdlog.git
            GIT_TAG v1.15.3
        )
        
        set(SPDLOG_ENABLE_PCH ON CACHE BOOL "Enable precompiled headers" FORCE)
        set(SPDLOG_BUILD_SHARED OFF CACHE BOOL "Build shared library" FORCE)
        set(SPDLOG_BUILD_EXAMPLES OFF CACHE BOOL "Build examples" FORCE)
        set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "Build tests" FORCE)
        set(SPDLOG_BUILD_BENCH OFF CACHE BOOL "Build benchmarks" FORCE)
        
        FetchContent_MakeAvailable(spdlog)
    endif()

    if(NOT TARGET qpcpp)
        FetchContent_Declare(
            qpcpp
            GIT_REPOSITORY https://github.com/QuantumLeaps/qpcpp.git
            GIT_TAG v7.3.4
        )
        
        set(QPCPP_CFG_PORT "posix" CACHE STRING "QPCPP port configuration")
        set(QPCPP_BUILD_EXAMPLES OFF CACHE BOOL "Build examples" FORCE)
        
        FetchContent_MakeAvailable(qpcpp)
    endif()

    if(NOT TARGET log4qt)
        FetchContent_Declare(
            log4qt
            GIT_REPOSITORY https://github.com/MEONMedical/Log4Qt.git
            GIT_TAG v1.5.1
        )
        
        set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared library" FORCE)
        set(BUILD_STATIC_LOG4CXX_LIB ON CACHE BOOL "Build static library" FORCE)
        set(LOG4QT_ENABLE_TESTS OFF CACHE BOOL "Enable Log4Qt tests" FORCE)
        set(LOG4QT_ENABLE_EXAMPLES OFF CACHE BOOL "Enable Log4Qt examples" FORCE)
        set(BUILD_WITH_DB_LOGGING OFF CACHE BOOL "Build with database logging support" FORCE)
        set(BUILD_WITH_TELNET_LOGGING ON CACHE BOOL "Build with telnet appender support" FORCE)
        set(BUILD_WITH_QML_LOGGING OFF CACHE BOOL "Build with QML logger support" FORCE)
        set(BUILD_WITH_DOCS OFF CACHE BOOL "Build documentation" FORCE)

        FetchContent_MakeAvailable(log4qt)
    endif()

    if(NOT TARGET SndFile::sndfile)
        FetchContent_Declare(
            libsndfile
            GIT_REPOSITORY https://github.com/libsndfile/libsndfile.git
            GIT_TAG 1.2.2
        )
        
        set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared library" FORCE)
        set(BUILD_PROGRAMS OFF CACHE BOOL "Build programs" FORCE)
        set(BUILD_EXAMPLES OFF CACHE BOOL "Build examples" FORCE)
        set(BUILD_TESTING OFF CACHE BOOL "Build tests" FORCE)
        set(ENABLE_EXTERNAL_LIBS ON CACHE BOOL "Enable external libraries support" FORCE)
        set(ENABLE_MPEG OFF CACHE BOOL "Enable MPEG support" FORCE)
        
        FetchContent_MakeAvailable(libsndfile)
    endif()

    set(GRPC_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/grpc-build")
    set(GRPC_INSTALL_DIR "${GRPC_PREFIX}/install")
    set(GRPC_INCLUDE_DIR "${GRPC_INSTALL_DIR}/include")
    set(GRPC_LIB_DIR "${GRPC_INSTALL_DIR}/lib")

    set(GRPC_CMAKE_ARGS
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_INSTALL_PREFIX=${GRPC_INSTALL_DIR}
        -DCMAKE_CXX_STANDARD=14
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCMAKE_CXX_EXTENSIONS=OFF
        -DgRPC_BUILD_TESTS=OFF
        -DgRPC_BUILD_CSHARP_EXT=OFF
        -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF
        -DgRPC_ABSL_PROVIDER=module
        -DgRPC_CARES_PROVIDER=module
        -DgRPC_PROTOBUF_PROVIDER=module
        -DgRPC_RE2_PROVIDER=module
        -DgRPC_SSL_PROVIDER=module
        -DgRPC_ZLIB_PROVIDER=module
        -DBUILD_SHARED_LIBS=OFF
    )

    ExternalProject_Add(grpc_external
        GIT_REPOSITORY https://github.com/grpc/grpc.git
        GIT_TAG v1.48.2
        GIT_SUBMODULES_RECURSE ON
        PREFIX ${GRPC_PREFIX}
        CMAKE_ARGS ${GRPC_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build . --parallel ${CMAKE_BUILD_PARALLEL_LEVEL}
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD ON
        LOG_INSTALL ON
    )

    find_package(OpenSSL REQUIRED)
    find_package(ZLIB REQUIRED)

    add_library(grpc++ STATIC IMPORTED)
    add_library(grpc STATIC IMPORTED)
    add_library(gpr STATIC IMPORTED)
    add_library(address_sorting STATIC IMPORTED)
    add_library(upb STATIC IMPORTED)
    add_library(protobuf::libprotobuf STATIC IMPORTED)
    add_library(re2::re2 STATIC IMPORTED)
    add_library(c-ares::cares STATIC IMPORTED)

    set_target_properties(grpc++ PROPERTIES
        IMPORTED_LOCATION "${GRPC_LIB_DIR}/libgrpc++.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GRPC_INCLUDE_DIR}"
    )
    
    set_target_properties(grpc PROPERTIES
        IMPORTED_LOCATION "${GRPC_LIB_DIR}/libgrpc.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GRPC_INCLUDE_DIR}"
    )
    
    set_target_properties(gpr PROPERTIES
        IMPORTED_LOCATION "${GRPC_LIB_DIR}/libgpr.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GRPC_INCLUDE_DIR}"
    )
    
    set_target_properties(address_sorting PROPERTIES
        IMPORTED_LOCATION "${GRPC_LIB_DIR}/libaddress_sorting.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GRPC_INCLUDE_DIR}"
    )
    
    set_target_properties(upb PROPERTIES
        IMPORTED_LOCATION "${GRPC_LIB_DIR}/libupb.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GRPC_INCLUDE_DIR}"
    )

    set_target_properties(protobuf::libprotobuf PROPERTIES
        IMPORTED_LOCATION "${GRPC_LIB_DIR}/libprotobuf.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GRPC_INCLUDE_DIR}"
    )

    set_target_properties(re2::re2 PROPERTIES
        IMPORTED_LOCATION "${GRPC_LIB_DIR}/libre2.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GRPC_INCLUDE_DIR}"
    )

    set_target_properties(c-ares::cares PROPERTIES
        IMPORTED_LOCATION "${GRPC_LIB_DIR}/libcares.a"
        INTERFACE_INCLUDE_DIRECTORIES "${GRPC_INCLUDE_DIR}"
    )

    add_dependencies(grpc++ grpc_external)
    add_dependencies(grpc grpc_external)
    add_dependencies(gpr grpc_external)
    add_dependencies(address_sorting grpc_external)
    add_dependencies(upb grpc_external)
    add_dependencies(protobuf::libprotobuf grpc_external)
    add_dependencies(re2::re2 grpc_external)
    add_dependencies(c-ares::cares grpc_external)

    add_executable(grpc_cpp_plugin IMPORTED)
    set_target_properties(grpc_cpp_plugin PROPERTIES
        IMPORTED_LOCATION "${GRPC_INSTALL_DIR}/bin/grpc_cpp_plugin"
    )
    add_dependencies(grpc_cpp_plugin grpc_external)

    target_link_libraries(grpc++ INTERFACE
        grpc
        gpr
        address_sorting
        upb
        protobuf::libprotobuf
        re2::re2
        c-ares::cares
        OpenSSL::SSL
        OpenSSL::Crypto
        ZLIB::ZLIB
        ${CMAKE_DL_LIBS}
    )
endmacro()

macro(link_alumy_dependencies target_name)
    target_link_libraries(${target_name} INTERFACE spdlog::spdlog qpcpp log4qt SndFile::sndfile grpc++)
endmacro()
