include(FetchContent)

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

    if(NOT TARGET grpc)
        FetchContent_Declare(
            grpc
            GIT_REPOSITORY https://github.com/grpc/grpc.git
            GIT_TAG v1.48.2
        )
        
        set(gRPC_BUILD_TESTS OFF CACHE BOOL "Build tests" FORCE)
        set(gRPC_BUILD_CSHARP_EXT OFF CACHE BOOL "Build C# extension" FORCE)
        set(gRPC_BUILD_GRPC_CSHARP_PLUGIN OFF CACHE BOOL "Build C# plugin" FORCE)
        set(gRPC_BUILD_GRPC_NODE_PLUGIN OFF CACHE BOOL "Build Node.js plugin" FORCE)
        set(gRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN OFF CACHE BOOL "Build Objective-C plugin" FORCE)
        set(gRPC_BUILD_GRPC_PHP_PLUGIN OFF CACHE BOOL "Build PHP plugin" FORCE)
        set(gRPC_BUILD_GRPC_PYTHON_PLUGIN OFF CACHE BOOL "Build Python plugin" FORCE)
        set(gRPC_BUILD_GRPC_RUBY_PLUGIN OFF CACHE BOOL "Build Ruby plugin" FORCE)

        set(gRPC_ABSL_PROVIDER "module" CACHE STRING "Provider of absl library" FORCE)
        set(gRPC_CARES_PROVIDER "module" CACHE STRING "Provider of c-ares library" FORCE)  
        set(gRPC_PROTOBUF_PROVIDER "module" CACHE STRING "Provider of protobuf library" FORCE)
        set(gRPC_RE2_PROVIDER "module" CACHE STRING "Provider of re2 library" FORCE)
        set(gRPC_SSL_PROVIDER "module" CACHE STRING "Provider of ssl library" FORCE)
        set(gRPC_ZLIB_PROVIDER "module" CACHE STRING "Provider of zlib library" FORCE)

        FetchContent_MakeAvailable(grpc)

        set_target_properties(grpc++ PROPERTIES
            CXX_STANDARD 14
            CXX_STANDARD_REQUIRED ON
            CXX_EXTENSIONS OFF
        )

        file(GLOB_RECURSE PROTO_GEN "${CMAKE_CURRENT_BINARY_DIR}/gens/src/proto/**/*.pb.*")
        if(PROTO_GEN)
            set_source_files_properties(${PROTO_GEN} PROPERTIES SKIP_AUTOGEN ON)
        endif()
    endif()
endmacro()

macro(link_alumy_dependencies target_name)
    target_link_libraries(${target_name} INTERFACE spdlog::spdlog qpcpp log4qt grpc)
endmacro()
