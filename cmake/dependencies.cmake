include(ExternalProject)
include(ProcessorCount)
include(${CMAKE_CURRENT_LIST_DIR}/ccache.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/qmake.cmake)

macro(configure_alumy_dependencies)
    ProcessorCount(N_CORES)

    set(EXTERNAL_INSTALL_DIR ${CMAKE_BINARY_DIR}/external-install)
    list(APPEND CMAKE_PREFIX_PATH ${EXTERNAL_INSTALL_DIR})

    set(HOST_TOOLS_INSTALL_DIR ${CMAKE_BINARY_DIR}/host-tools-install)

    # spdlog
    set(SPDLOG_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=ON
        -DSPDLOG_ENABLE_PCH=ON
        -DSPDLOG_BUILD_SHARED=ON
        -DSPDLOG_BUILD_TESTS=OFF
        -DSPDLOG_BUILD_BENCH=OFF
        -DSPDLOG_BUILD_EXAMPLE=OFF
        -DSPDLOG_INSTALL=ON
    )

    ExternalProject_Add(spdlog-external
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG v1.15.3
        GIT_SHALLOW ON
        CMAKE_ARGS ${SPDLOG_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libspdlog.so
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    # qpcpp
    set(QPCPP_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
        -DQPCPP_CFG_KERNEL=qv
        -DQPCPP_CFG_PORT=posix
        -DQPCPP_CFG_GUI=OFF
        -DQPCPP_CFG_UNIT_TEST=OFF
        -DQPCPP_CFG_VERBOSE=OFF
    )
    
    ExternalProject_Add(qpcpp-external
        GIT_REPOSITORY https://github.com/QuantumLeaps/qpcpp.git
        GIT_TAG v7.3.4
        GIT_SHALLOW ON
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/cmake/qpcpp_force_cxx.cmake <SOURCE_DIR>/force_cxx.cmake
            COMMAND sed -i "1i include(force_cxx.cmake)" <SOURCE_DIR>/CMakeLists.txt
        CMAKE_ARGS ${QPCPP_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS 
            ${EXTERNAL_INSTALL_DIR}/lib/libqpcpp.a
        INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${EXTERNAL_INSTALL_DIR}/lib
            COMMAND ${CMAKE_COMMAND} -E make_directory ${EXTERNAL_INSTALL_DIR}/include
            COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libqpcpp.a ${EXTERNAL_INSTALL_DIR}/lib/
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include ${EXTERNAL_INSTALL_DIR}/include
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/src ${EXTERNAL_INSTALL_DIR}/include
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/ports/posix-qv ${EXTERNAL_INSTALL_DIR}/include/ports/posix-qv
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    # log4qt
    set(LOG4QT_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=ON
        -DBUILD_STATIC_LOG4CXX_LIB=OFF
        -DBUILD_WITH_DB_LOGGING=OFF
        -DBUILD_WITH_TELNET_LOGGING=ON
        -DBUILD_WITH_DOCS=OFF
    )

    ExternalProject_Add(log4qt-external
        GIT_REPOSITORY https://github.com/MEONMedical/Log4Qt.git
        GIT_TAG v1.5.1
        GIT_SHALLOW ON
        PATCH_COMMAND sed -i "s/add_subdirectory(tests)/#add_subdirectory(tests)/" CMakeLists.txt
            COMMAND sed -i "s/add_subdirectory(examples)/#add_subdirectory(examples)/" CMakeLists.txt
        CMAKE_ARGS ${LOG4QT_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/liblog4qt.so
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    # libsndfile
    set(LIBSNDFILE_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_C_STANDARD=11
        -DCMAKE_C_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=ON
        -DBUILD_PROGRAMS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_EXTERNAL_LIBS=OFF
        -DENABLE_MPEG=OFF
        -DINSTALL_MANPAGES=OFF
    )

    ExternalProject_Add(libsndfile-external
        GIT_REPOSITORY https://github.com/libsndfile/libsndfile.git
        GIT_TAG 1.2.2
        GIT_SHALLOW ON
        CMAKE_ARGS ${LIBSNDFILE_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libsndfile.so
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    # yaml-cpp
    set(YAMLCPP_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=ON
        -DYAML_CPP_BUILD_TESTS=OFF
        -DYAML_CPP_BUILD_TOOLS=OFF
        -DYAML_CPP_BUILD_CONTRIB=OFF
        -DYAML_CPP_FORMAT_SOURCE=OFF
        -DYAML_BUILD_SHARED_LIBS=ON
        -DYAML_CPP_INSTALL=ON
    )

    ExternalProject_Add(yaml-cpp-external
        GIT_REPOSITORY https://github.com/jbeder/yaml-cpp.git
        GIT_TAG 0.8.0
        GIT_SHALLOW ON
        CMAKE_ARGS ${YAMLCPP_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libyaml-cpp.so
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    # OpenSSL
    message(STATUS "Configuring bundled OpenSSL build")

    # Determine OpenSSL target based on CMAKE_SYSTEM_PROCESSOR
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(OPENSSL_TARGET "linux-aarch64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^arm")
        set(OPENSSL_TARGET "linux-armv4")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64")
        set(OPENSSL_TARGET "linux-x86_64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "i.86")
        set(OPENSSL_TARGET "linux-x86")
    else()
        set(OPENSSL_TARGET "linux-generic64")
    endif()

    message(STATUS "OpenSSL target: ${OPENSSL_TARGET} (CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR})")

    set(OPENSSL_CONFIGURE_COMMAND 
        ${CMAKE_COMMAND} -E env "CC=${CCACHE_CC}"
        <SOURCE_DIR>/Configure
            ${OPENSSL_TARGET}
            --prefix=<INSTALL_DIR>
            --openssldir=<INSTALL_DIR>/ssl
            --libdir=lib
            shared
            no-tests
            -DOPENSSL_USE_NODELETE
    )
    
    ExternalProject_Add(openssl-external
        GIT_REPOSITORY https://github.com/openssl/openssl.git
        GIT_TAG openssl-3.0.17
        GIT_SHALLOW ON
        INSTALL_DIR ${EXTERNAL_INSTALL_DIR}
        CONFIGURE_COMMAND ${OPENSSL_CONFIGURE_COMMAND}
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libssl.so
            ${EXTERNAL_INSTALL_DIR}/lib/libcrypto.so
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install_sw
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    # Protobuf for host (build protoc executable for code generation)
    set(PROTOBUF_HOST_CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${HOST_TOOLS_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
        -Dprotobuf_BUILD_TESTS=OFF
        -Dprotobuf_BUILD_EXAMPLES=OFF
        -Dprotobuf_BUILD_CONFORMANCE=OFF
        -Dprotobuf_BUILD_LIBPROTOC=ON
        -Dprotobuf_BUILD_PROTOC_BINARIES=ON
        -Dprotobuf_BUILD_SHARED_LIBS=OFF
        -Dprotobuf_WITH_ZLIB=OFF
        -Dprotobuf_MSVC_STATIC_RUNTIME=OFF
    )

    ExternalProject_Add(protobuf-host
        GIT_REPOSITORY https://github.com/protocolbuffers/protobuf.git
        GIT_TAG v3.21.12
        GIT_SHALLOW ON
        CMAKE_ARGS ${PROTOBUF_HOST_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${HOST_TOOLS_INSTALL_DIR}/bin/protoc
            ${HOST_TOOLS_INSTALL_DIR}/lib/libprotobuf.a
            ${HOST_TOOLS_INSTALL_DIR}/lib/libprotoc.a
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    set(PROTOC_EXECUTABLE ${HOST_TOOLS_INSTALL_DIR}/bin/protoc)
    message(STATUS "Will use host protoc: ${PROTOC_EXECUTABLE}")

    # Protobuf for target (libraries only, use host protoc)
    set(PROTOBUF_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=ON
        -Dprotobuf_BUILD_TESTS=OFF
        -Dprotobuf_BUILD_EXAMPLES=OFF
        -Dprotobuf_BUILD_CONFORMANCE=OFF
        -Dprotobuf_BUILD_LIBPROTOC=ON
        -Dprotobuf_BUILD_PROTOC_BINARIES=OFF
        -Dprotobuf_BUILD_SHARED_LIBS=ON
        -Dprotobuf_WITH_ZLIB=OFF
        -Dprotobuf_MSVC_STATIC_RUNTIME=OFF
    )

    ExternalProject_Add(protobuf-external
        GIT_REPOSITORY https://github.com/protocolbuffers/protobuf.git
        GIT_TAG v3.21.12
        GIT_SHALLOW ON
        CMAKE_ARGS ${PROTOBUF_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libprotobuf.so
            ${EXTERNAL_INSTALL_DIR}/lib/libprotobuf-lite.so
            ${EXTERNAL_INSTALL_DIR}/lib/libprotoc.so
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
        DEPENDS protobuf-host
    )

    # gRPC for host (build grpc_cpp_plugin for code generation)
    set(GRPC_HOST_CMAKE_ARGS
        -DCMAKE_PREFIX_PATH=${HOST_TOOLS_INSTALL_DIR}
        -DCMAKE_INSTALL_PREFIX=${HOST_TOOLS_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
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
        -DgRPC_PROTOBUF_PROVIDER=package
        -DgRPC_RE2_PROVIDER=module
        -DgRPC_SSL_PROVIDER=module
        -DgRPC_ZLIB_PROVIDER=module
        -DgRPC_BENCHMARK_PROVIDER=none
        -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON
        -DgRPC_BUILD_CODEGEN=ON
        -DgRPC_INSTALL=ON
        -DABSL_PROPAGATE_CXX_STD=ON
        -DABSL_ENABLE_INSTALL=ON
        -DProtobuf_DIR=${HOST_TOOLS_INSTALL_DIR}/lib/cmake/protobuf
    )

    ExternalProject_Add(grpc-host
        GIT_REPOSITORY https://github.com/grpc/grpc.git
        GIT_TAG v1.46.7
        GIT_SUBMODULES_RECURSE ON
        GIT_SHALLOW ON
        CMAKE_ARGS ${GRPC_HOST_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build . --target grpc_cpp_plugin
        BUILD_BYPRODUCTS
            ${HOST_TOOLS_INSTALL_DIR}/bin/grpc_cpp_plugin
        INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/grpc_cpp_plugin ${HOST_TOOLS_INSTALL_DIR}/bin/grpc_cpp_plugin
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
        DEPENDS protobuf-host
    )

    set(GRPC_CPP_PLUGIN_EXECUTABLE ${HOST_TOOLS_INSTALL_DIR}/bin/grpc_cpp_plugin)

    set(GRPC_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=ON
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
        -DgRPC_PROTOBUF_PROVIDER=package
        -DgRPC_RE2_PROVIDER=module
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_ZLIB_PROVIDER=module
        -DgRPC_BENCHMARK_PROVIDER=none
        -DgRPC_BUILD_GRPC_CPP_PLUGIN=OFF
        -DgRPC_BUILD_CODEGEN=OFF
        -DgRPC_INSTALL=ON
        -DgRPC_BACKWARDS_COMPATIBILITY_MODE=OFF
        -DABSL_PROPAGATE_CXX_STD=ON
        -DABSL_ENABLE_INSTALL=ON
        -DRE2_BUILD_TESTING=OFF
        -DCARES_STATIC=OFF
        -DCARES_SHARED=ON
        -DCARES_BUILD_TESTS=OFF
        -DCARES_BUILD_TOOLS=OFF
        -DZLIB_BUILD_SHARED=ON
        -DZLIB_BUILD_STATIC=OFF
        -DOPENSSL_ROOT_DIR=${EXTERNAL_INSTALL_DIR}
        -DOPENSSL_INCLUDE_DIR=${EXTERNAL_INSTALL_DIR}/include
        -DOPENSSL_CRYPTO_LIBRARY=${EXTERNAL_INSTALL_DIR}/lib/libcrypto.so
        -DOPENSSL_SSL_LIBRARY=${EXTERNAL_INSTALL_DIR}/lib/libssl.so
        -DProtobuf_DIR=${EXTERNAL_INSTALL_DIR}/lib/cmake/protobuf
        -DProtobuf_PROTOC_EXECUTABLE=${PROTOC_EXECUTABLE}
        -D_gRPC_CPP_PLUGIN=${GRPC_CPP_PLUGIN_EXECUTABLE}
    )
    
    set(GRPC_BUILD_BYPRODUCTS
        ${EXTERNAL_INSTALL_DIR}/lib/libgrpc++.so
        ${EXTERNAL_INSTALL_DIR}/lib/libgrpc.so
        ${EXTERNAL_INSTALL_DIR}/lib/libgpr.so
        ${EXTERNAL_INSTALL_DIR}/lib/libaddress_sorting.so
        ${EXTERNAL_INSTALL_DIR}/lib/libupb.so
        ${EXTERNAL_INSTALL_DIR}/lib/libabsl_*.so
        ${EXTERNAL_INSTALL_DIR}/lib/libre2.so
        ${EXTERNAL_INSTALL_DIR}/lib/libcares.so
        ${EXTERNAL_INSTALL_DIR}/lib/libz.so
    )
    
    ExternalProject_Add(grpc-external
        GIT_REPOSITORY https://github.com/grpc/grpc.git
        GIT_TAG v1.46.7
        GIT_SUBMODULES_RECURSE ON
        GIT_SHALLOW ON
        CMAKE_ARGS ${GRPC_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS ${GRPC_BUILD_BYPRODUCTS}
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
        DEPENDS openssl-external protobuf-external grpc-host
    )

    # Boost
    set(BOOST_B2_OPTIONS variant=release link=shared runtime-link=shared threading=multi cxxstd=11)

    if(NOT N_CORES EQUAL 0)
        set(BOOST_PARALLEL_JOBS ${N_CORES})
    else()
        set(BOOST_PARALLEL_JOBS 4)
    endif()

    file(WRITE ${CMAKE_BINARY_DIR}/user-config.jam 
        "using gcc : cross : ${CCACHE_CXX} ;\n")
    set(BOOST_TOOLSET "toolset=gcc-cross")

    ExternalProject_Add(boost-external
        GIT_REPOSITORY https://github.com/boostorg/boost.git
        GIT_TAG boost-1.75.0
        GIT_SHALLOW ON
        GIT_SUBMODULES_RECURSE ON
        INSTALL_DIR ${EXTERNAL_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./bootstrap.sh --prefix=<INSTALL_DIR>
        BUILD_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./b2 -j${BOOST_PARALLEL_JOBS} ${BOOST_TOOLSET} ${BOOST_B2_OPTIONS} --user-config=${CMAKE_BINARY_DIR}/user-config.jam --prefix=<INSTALL_DIR> headers
            COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./b2 -j${BOOST_PARALLEL_JOBS} ${BOOST_TOOLSET} ${BOOST_B2_OPTIONS} --user-config=${CMAKE_BINARY_DIR}/user-config.jam --prefix=<INSTALL_DIR> --with-system --with-filesystem --with-thread --with-chrono --with-date_time install
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libboost_system.so
            ${EXTERNAL_INSTALL_DIR}/lib/libboost_filesystem.so
            ${EXTERNAL_INSTALL_DIR}/lib/libboost_thread.so
            ${EXTERNAL_INSTALL_DIR}/lib/libboost_chrono.so
            ${EXTERNAL_INSTALL_DIR}/lib/libboost_date_time.so
        INSTALL_COMMAND ""
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    set(BOOST_ROOT ${EXTERNAL_INSTALL_DIR} CACHE PATH "" FORCE)
    set(BOOST_INCLUDEDIR ${EXTERNAL_INSTALL_DIR}/include CACHE PATH "" FORCE)
    set(BOOST_LIBRARYDIR ${EXTERNAL_INSTALL_DIR}/lib CACHE PATH "" FORCE)
    set(Boost_NO_SYSTEM_PATHS ON CACHE BOOL "" FORCE)
    set(Boost_USE_STATIC_LIBS OFF CACHE BOOL "" FORCE)

    # libcoap
    set(LIBCOAP_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_C_STANDARD=11
        -DCMAKE_C_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=ON
        -DENABLE_DTLS=ON
        -DENABLE_TCP=ON
        -DENABLE_OSCORE=ON
        -DDTLS_BACKEND=openssl
        -DENABLE_EXAMPLES=OFF
        -DENABLE_DOCS=OFF
        -DENABLE_TESTS=OFF
        -DOPENSSL_ROOT_DIR=${EXTERNAL_INSTALL_DIR}
        -DOPENSSL_INCLUDE_DIR=${EXTERNAL_INSTALL_DIR}/include
        -DOPENSSL_CRYPTO_LIBRARY=${EXTERNAL_INSTALL_DIR}/lib/libcrypto.so
        -DOPENSSL_SSL_LIBRARY=${EXTERNAL_INSTALL_DIR}/lib/libssl.so
    )

    ExternalProject_Add(libcoap-external
        GIT_REPOSITORY https://github.com/obgm/libcoap.git
        GIT_TAG v4.3.5
        GIT_SHALLOW ON
        CMAKE_ARGS ${LIBCOAP_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libcoap-3.so
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
        DEPENDS openssl-external
    )

    # libcoap-notls (without DTLS support)
    set(LIBCOAP_NOTLS_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_C_STANDARD=11
        -DCMAKE_C_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=ON
        -DENABLE_DTLS=OFF
        -DENABLE_TCP=ON
        -DENABLE_OSCORE=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_DOCS=OFF
        -DENABLE_TESTS=OFF
    )

    ExternalProject_Add(libcoap-notls-external
        GIT_REPOSITORY https://github.com/obgm/libcoap.git
        GIT_TAG v4.3.5
        GIT_SHALLOW ON
        CMAKE_ARGS ${LIBCOAP_NOTLS_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libcoap-3-notls.so
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    message(STATUS "Autotools build triplet: ${AUTOTOOLS_BUILD_TRIPLET}")
    message(STATUS "Autotools host triplet: ${AUTOTOOLS_HOST_TRIPLET}")

    # libite (dependency of watchdogd)
    ExternalProject_Add(libite-external
        GIT_REPOSITORY https://github.com/troglobit/libite.git
        GIT_TAG v2.6.1
        GIT_SHALLOW ON
        INSTALL_DIR ${EXTERNAL_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh
            COMMAND ${CMAKE_COMMAND} -E env "CC=${CCACHE_CC}" "PKG_CONFIG_PATH=${EXTERNAL_INSTALL_DIR}/lib/pkgconfig"
                <SOURCE_DIR>/configure
                    --prefix=<INSTALL_DIR>
                    --build=${AUTOTOOLS_BUILD_TRIPLET}
                    --host=${AUTOTOOLS_HOST_TRIPLET}
                    --disable-static
                    --enable-shared
                    --without-symlink
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libite.so
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    # libuEv (dependency of watchdogd)
    ExternalProject_Add(libuev-external
        GIT_REPOSITORY https://github.com/troglobit/libuev.git
        GIT_TAG v2.4.1
        GIT_SHALLOW ON
        INSTALL_DIR ${EXTERNAL_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh
            COMMAND ${CMAKE_COMMAND} -E env "CC=${CCACHE_CC}" "PKG_CONFIG_PATH=${EXTERNAL_INSTALL_DIR}/lib/pkgconfig"
                <SOURCE_DIR>/configure
                    --prefix=<INSTALL_DIR>
                    --build=${AUTOTOOLS_BUILD_TRIPLET}
                    --host=${AUTOTOOLS_HOST_TRIPLET}
                    --disable-static
                    --enable-shared
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libuev.so
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    # libConfuse (dependency of watchdogd)
    ExternalProject_Add(libconfuse-external
        GIT_REPOSITORY https://github.com/libconfuse/libconfuse.git
        GIT_TAG v3.3
        GIT_SHALLOW ON
        INSTALL_DIR ${EXTERNAL_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh
            COMMAND ${CMAKE_COMMAND} -E env "CC=${CCACHE_CC}" "PKG_CONFIG_PATH=${EXTERNAL_INSTALL_DIR}/lib/pkgconfig"
                <SOURCE_DIR>/configure
                    --prefix=<INSTALL_DIR>
                    --build=${AUTOTOOLS_BUILD_TRIPLET}
                    --host=${AUTOTOOLS_HOST_TRIPLET}
                    --disable-static
                    --enable-shared
                    --disable-examples
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libconfuse.so
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    # watchdogd
    ExternalProject_Add(watchdogd-external
        GIT_REPOSITORY https://github.com/troglobit/watchdogd.git
        GIT_TAG 3.5
        GIT_SHALLOW ON
        INSTALL_DIR ${EXTERNAL_INSTALL_DIR}
        PATCH_COMMAND patch --forward --fuzz=3 -p0 -d <SOURCE_DIR> -i ${CMAKE_SOURCE_DIR}/cmake/patches/watchdogd-confdir.patch || true
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh
            COMMAND ${CMAKE_COMMAND} -E env 
                "CC=${CCACHE_CC}"
                "CPPFLAGS=-I${EXTERNAL_INSTALL_DIR}/include"
                "LDFLAGS=-L${EXTERNAL_INSTALL_DIR}/lib"
                "PKG_CONFIG_PATH=${EXTERNAL_INSTALL_DIR}/lib/pkgconfig"
                <SOURCE_DIR>/configure
                    --build=${AUTOTOOLS_BUILD_TRIPLET}
                    --host=${AUTOTOOLS_HOST_TRIPLET}
                    --prefix=<INSTALL_DIR>
                    --sysconfdir=/etc
                    --localstatedir=/var
                    --disable-static
                    --enable-shared
                    --with-systemd=no
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libwdog.so
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
        DEPENDS libite-external libuev-external libconfuse-external
    )

    # libmodbus
    ExternalProject_Add(libmodbus-external
        GIT_REPOSITORY https://github.com/stephane/libmodbus.git
        GIT_TAG v3.1.11
        GIT_SHALLOW ON
        INSTALL_DIR ${EXTERNAL_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh
            COMMAND ${CMAKE_COMMAND} -E env "CC=${CCACHE_CC}" "PKG_CONFIG_PATH=${EXTERNAL_INSTALL_DIR}/lib/pkgconfig"
                <SOURCE_DIR>/configure
                    --prefix=<INSTALL_DIR>
                    --build=${AUTOTOOLS_BUILD_TRIPLET}
                    --host=${AUTOTOOLS_HOST_TRIPLET}
                    --disable-static
                    --enable-shared
                    --disable-tests
                    --without-documentation
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libmodbus.so
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    ExternalProject_Add(qwt-external
        GIT_REPOSITORY https://github.com/opencor/qwt.git
        GIT_TAG v6.2.0
        GIT_SHALLOW ON
        INSTALL_DIR ${EXTERNAL_INSTALL_DIR}
        PATCH_COMMAND sed -i "s|QWT_INSTALL_PREFIX = .*\\[QT_INSTALL_PREFIX\\]|QWT_INSTALL_PREFIX = <INSTALL_DIR>|" <SOURCE_DIR>/qwtconfig.pri
        CONFIGURE_COMMAND ${QMAKE} <SOURCE_DIR>/qwt.pro 
            "QMAKE_CC=${CCACHE_CC}"
            "QMAKE_CXX=${CCACHE_CXX}"
            "QMAKE_LINK=${CMAKE_CXX_COMPILER}"
            "QMAKE_AR=${CMAKE_AR} cqs"
            "QWT_CONFIG-=QwtStatic"
            "QWT_CONFIG+=QwtDll"
            "QWT_CONFIG-=QwtExamples"
            "QWT_CONFIG-=QwtDesigner"
            "INSTALL_DIR=<INSTALL_DIR>"
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${EXTERNAL_INSTALL_DIR}/lib/libqwt.so
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )
endmacro()

macro(install_alumy_dependencies)
    set(EXTERNAL_INSTALL_DIR ${CMAKE_BINARY_DIR}/external-install)
    set(HOST_TOOLS_INSTALL_DIR ${CMAKE_BINARY_DIR}/host-tools-install)

    install(DIRECTORY ${EXTERNAL_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)

    install(DIRECTORY ${HOST_TOOLS_INSTALL_DIR}/
        DESTINATION "../host"
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(add_alumy_dependencies target)
    add_dependencies(${target} 
        spdlog-external 
        qpcpp-external 
        log4qt-external 
        libsndfile-external 
        yaml-cpp-external 
        protobuf-external
        grpc-external 
        openssl-external 
        boost-external 
        libcoap-external
        libcoap-notls-external
        libite-external
        libuev-external
        libconfuse-external
        watchdogd-external
        libmodbus-external
        qwt-external
    )
endmacro()

macro(link_alumy_dependencies target)
    set(EXTERNAL_INSTALL_DIR ${CMAKE_BINARY_DIR}/external-install)

    target_include_directories(${target} PUBLIC
        $<BUILD_INTERFACE:${EXTERNAL_INSTALL_DIR}/include>
        $<INSTALL_INTERFACE:include>
    )

    target_link_directories(${target} PUBLIC
        $<BUILD_INTERFACE:${EXTERNAL_INSTALL_DIR}/lib>
        $<INSTALL_INTERFACE:lib>
    )

    target_link_libraries(${target} PUBLIC
        boost_system
        boost_filesystem
        boost_thread
        boost_chrono
        boost_date_time
        log4qt
        sndfile
        spdlog
        yaml-cpp
        qpcpp
        qwt
        grpc++
        grpc
        gpr
        address_sorting
        upb
        protobuf
        coap-3
        modbus
        wdog
        ite
        uev
        confuse
        ssl 
        crypto
        pthread
        dl
        m
    )
endmacro()
