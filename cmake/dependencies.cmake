include(ExternalProject)

macro(configure_alumy_dependencies)
    # spdlog
    set(SPDLOG_INSTALL_DIR ${CMAKE_BINARY_DIR}/spdlog-install)

    set(SPDLOG_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${SPDLOG_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
        -DSPDLOG_ENABLE_PCH=ON
        -DSPDLOG_BUILD_SHARED=OFF
        -DSPDLOG_BUILD_TESTS=OFF
        -DSPDLOG_BUILD_BENCH=OFF
        -DSPDLOG_BUILD_EXAMPLE=OFF
        -DSPDLOG_INSTALL=ON
    )
    if(CCACHE_PROGRAM)
        list(APPEND SPDLOG_CMAKE_ARGS
            -DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_PROGRAM}
            -DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_PROGRAM})
    endif()

    ExternalProject_Add(spdlog-external
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG v1.15.3
        GIT_SHALLOW ON
        CMAKE_ARGS ${SPDLOG_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${SPDLOG_INSTALL_DIR}/lib/libspdlog.a
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${SPDLOG_INSTALL_DIR})

    # qpcpp
    set(QPCPP_INSTALL_DIR ${CMAKE_BINARY_DIR}/qpcpp-install)
    
    set(QPCPP_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${QPCPP_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
        -DQPCPP_CFG_KERNEL=qv
        -DQPCPP_CFG_PORT=posix
        -DQPCPP_CFG_GUI=OFF
        -DQPCPP_CFG_UNIT_TEST=OFF
        -DQPCPP_CFG_VERBOSE=OFF
    )
    if(CCACHE_PROGRAM)
        list(APPEND QPCPP_CMAKE_ARGS
            -DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_PROGRAM}
            -DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_PROGRAM})
    endif()
    
    ExternalProject_Add(qpcpp-external
        GIT_REPOSITORY https://github.com/QuantumLeaps/qpcpp.git
        GIT_TAG v7.3.4
        GIT_SHALLOW ON
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/cmake/qpcpp_force_cxx.cmake <SOURCE_DIR>/force_cxx.cmake
            COMMAND sed -i "1i include(force_cxx.cmake)" <SOURCE_DIR>/CMakeLists.txt
        CMAKE_ARGS ${QPCPP_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS 
            ${QPCPP_INSTALL_DIR}/lib/libqpcpp.a
        INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${QPCPP_INSTALL_DIR}/lib
            COMMAND ${CMAKE_COMMAND} -E make_directory ${QPCPP_INSTALL_DIR}/include
            COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libqpcpp.a ${QPCPP_INSTALL_DIR}/lib/
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include ${QPCPP_INSTALL_DIR}/include
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/src ${QPCPP_INSTALL_DIR}/include
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/ports/posix-qv ${QPCPP_INSTALL_DIR}/include/ports/posix-qv
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${QPCPP_INSTALL_DIR})

    # log4qt
    set(LOG4QT_INSTALL_DIR ${CMAKE_BINARY_DIR}/log4qt-install)

    set(LOG4QT_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${LOG4QT_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_STATIC_LOG4CXX_LIB=ON
        -DBUILD_WITH_DB_LOGGING=OFF
        -DBUILD_WITH_TELNET_LOGGING=ON
        -DBUILD_WITH_DOCS=OFF
    )
    if(CCACHE_PROGRAM)
        list(APPEND LOG4QT_CMAKE_ARGS
            -DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_PROGRAM}
            -DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_PROGRAM})
    endif()

    ExternalProject_Add(log4qt-external
        GIT_REPOSITORY https://github.com/MEONMedical/Log4Qt.git
        GIT_TAG v1.5.1
        GIT_SHALLOW ON
        PATCH_COMMAND sed -i "s/add_subdirectory(tests)/#add_subdirectory(tests)/" CMakeLists.txt
            COMMAND sed -i "s/add_subdirectory(examples)/#add_subdirectory(examples)/" CMakeLists.txt
        CMAKE_ARGS ${LOG4QT_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${LOG4QT_INSTALL_DIR}/lib/liblog4qt.a
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${LOG4QT_INSTALL_DIR})

    # libsndfile
    set(LIBSNDFILE_INSTALL_DIR ${CMAKE_BINARY_DIR}/libsndfile-install)

    set(LIBSNDFILE_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${LIBSNDFILE_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_STANDARD=11
        -DCMAKE_C_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_PROGRAMS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_EXTERNAL_LIBS=OFF
        -DENABLE_MPEG=OFF
        -DINSTALL_MANPAGES=OFF
    )
    if(CCACHE_PROGRAM)
        list(APPEND LIBSNDFILE_CMAKE_ARGS
            -DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_PROGRAM}
            -DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_PROGRAM})
    endif()

    ExternalProject_Add(libsndfile-external
        GIT_REPOSITORY https://github.com/libsndfile/libsndfile.git
        GIT_TAG 1.2.2
        GIT_SHALLOW ON
        CMAKE_ARGS ${LIBSNDFILE_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${LIBSNDFILE_INSTALL_DIR}/lib/libsndfile.a
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${LIBSNDFILE_INSTALL_DIR})

    # yaml-cpp
    set(YAMLCPP_INSTALL_DIR ${CMAKE_BINARY_DIR}/yaml-cpp-install)

    set(YAMLCPP_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${YAMLCPP_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
        -DYAML_CPP_BUILD_TESTS=OFF
        -DYAML_CPP_BUILD_TOOLS=OFF
        -DYAML_CPP_BUILD_CONTRIB=OFF
        -DYAML_CPP_FORMAT_SOURCE=OFF
        -DYAML_BUILD_SHARED_LIBS=OFF
        -DYAML_CPP_INSTALL=ON
    )
    if(CCACHE_PROGRAM)
        list(APPEND YAMLCPP_CMAKE_ARGS
            -DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_PROGRAM}
            -DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_PROGRAM})
    endif()

    ExternalProject_Add(yaml-cpp-external
        GIT_REPOSITORY https://github.com/jbeder/yaml-cpp.git
        GIT_TAG 0.8.0
        GIT_SHALLOW ON
        CMAKE_ARGS ${YAMLCPP_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${YAMLCPP_INSTALL_DIR}/lib/libyaml-cpp.a
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${YAMLCPP_INSTALL_DIR})

    # OpenSSL
    set(OPENSSL_INSTALL_DIR ${CMAKE_BINARY_DIR}/openssl-install)
    
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

    if(CCACHE_PROGRAM)
        set(OPENSSL_CC "${CCACHE_PROGRAM} ${CMAKE_C_COMPILER}")
    else()
        set(OPENSSL_CC "${CMAKE_C_COMPILER}")
    endif()
    set(OPENSSL_CONFIGURE_COMMAND 
        ${CMAKE_COMMAND} -E env "CC=${OPENSSL_CC}"
        <SOURCE_DIR>/Configure
            ${OPENSSL_TARGET}
            --prefix=<INSTALL_DIR>
            --openssldir=<INSTALL_DIR>/ssl
            --libdir=lib
            no-shared
            no-tests
            -DOPENSSL_USE_NODELETE
    )
    
    ExternalProject_Add(openssl-external
        GIT_REPOSITORY https://github.com/openssl/openssl.git
        GIT_TAG openssl-3.0.17
        GIT_SHALLOW ON
        INSTALL_DIR ${OPENSSL_INSTALL_DIR}
        CONFIGURE_COMMAND ${OPENSSL_CONFIGURE_COMMAND}
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${OPENSSL_INSTALL_DIR}/lib/libssl.a
            ${OPENSSL_INSTALL_DIR}/lib/libcrypto.a
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install_sw
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )
    
    list(APPEND CMAKE_PREFIX_PATH ${OPENSSL_INSTALL_DIR})

    # gRPC
    set(GRPC_INSTALL_DIR ${CMAKE_BINARY_DIR}/grpc-install)

    set(GRPC_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${GRPC_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
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
        -DgRPC_PROTOBUF_PROVIDER=module
        -DgRPC_RE2_PROVIDER=module
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_ZLIB_PROVIDER=module
        -DgRPC_BENCHMARK_PROVIDER=none
        -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON
        -DgRPC_BUILD_CODEGEN=ON
        -DgRPC_INSTALL=ON
        -DgRPC_BACKWARDS_COMPATIBILITY_MODE=OFF
        -DABSL_PROPAGATE_CXX_STD=ON
        -DABSL_ENABLE_INSTALL=ON
        -Dprotobuf_BUILD_TESTS=OFF
        -Dprotobuf_BUILD_EXAMPLES=OFF
        -Dprotobuf_WITH_ZLIB=OFF
        -Dprotobuf_BUILD_SHARED_LIBS=OFF
        -DRE2_BUILD_TESTING=OFF
        -DCARES_STATIC=ON
        -DCARES_SHARED=OFF
        -DCARES_BUILD_TESTS=OFF
        -DCARES_BUILD_TOOLS=OFF
        -DOPENSSL_ROOT_DIR=${OPENSSL_INSTALL_DIR}
        -DOPENSSL_INCLUDE_DIR=${OPENSSL_INSTALL_DIR}/include
        -DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_INSTALL_DIR}/lib/libcrypto.a
        -DOPENSSL_SSL_LIBRARY=${OPENSSL_INSTALL_DIR}/lib/libssl.a
    )
    if(CCACHE_PROGRAM)
        list(APPEND GRPC_CMAKE_ARGS
            -DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_PROGRAM}
            -DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_PROGRAM})
    endif()
    
    ExternalProject_Add(grpc-external
        GIT_REPOSITORY https://github.com/grpc/grpc.git
        GIT_TAG v1.46.7
        GIT_SUBMODULES_RECURSE ON
        GIT_SHALLOW ON
        CMAKE_ARGS ${GRPC_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS 
            ${GRPC_INSTALL_DIR}/lib/libgrpc++.a
            ${GRPC_INSTALL_DIR}/lib/libgrpc.a
            ${GRPC_INSTALL_DIR}/lib/libgpr.a
            ${GRPC_INSTALL_DIR}/lib/libaddress_sorting.a
            ${GRPC_INSTALL_DIR}/lib/libupb.a
            ${GRPC_INSTALL_DIR}/lib/libabsl_*.a
            ${GRPC_INSTALL_DIR}/lib/libprotobuf.a
            ${GRPC_INSTALL_DIR}/lib/libre2.a
            ${GRPC_INSTALL_DIR}/lib/libcares.a
            ${GRPC_INSTALL_DIR}/lib/libz.a
            ${GRPC_INSTALL_DIR}/bin/grpc_cpp_plugin
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
        DEPENDS openssl-external
    )

    list(APPEND CMAKE_PREFIX_PATH ${GRPC_INSTALL_DIR})

    # Boost
    set(BOOST_INSTALL_DIR ${CMAKE_BINARY_DIR}/boost-install)

    set(BOOST_B2_OPTIONS variant=release link=static runtime-link=static threading=multi cxxstd=11)

    include(ProcessorCount)
    ProcessorCount(N_CORES)
    if(NOT N_CORES EQUAL 0)
        set(BOOST_PARALLEL_JOBS ${N_CORES})
    else()
        set(BOOST_PARALLEL_JOBS 4)
    endif()

    if(CCACHE_PROGRAM)
        file(WRITE ${CMAKE_BINARY_DIR}/user-config.jam 
            "using gcc : cross : ${CCACHE_PROGRAM} ${CMAKE_CXX_COMPILER} ;\n")
    else()
        file(WRITE ${CMAKE_BINARY_DIR}/user-config.jam 
            "using gcc : cross : ${CMAKE_CXX_COMPILER} ;\n")
    endif()
    set(BOOST_TOOLSET "toolset=gcc-cross")

    ExternalProject_Add(boost-external
        GIT_REPOSITORY https://github.com/boostorg/boost.git
        GIT_TAG boost-1.75.0
        GIT_SHALLOW ON
        GIT_SUBMODULES_RECURSE ON
        INSTALL_DIR ${BOOST_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./bootstrap.sh --prefix=<INSTALL_DIR>
        BUILD_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./b2 -j${BOOST_PARALLEL_JOBS} ${BOOST_TOOLSET} ${BOOST_B2_OPTIONS} --user-config=${CMAKE_BINARY_DIR}/user-config.jam --prefix=<INSTALL_DIR> headers
            COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./b2 -j${BOOST_PARALLEL_JOBS} ${BOOST_TOOLSET} ${BOOST_B2_OPTIONS} --user-config=${CMAKE_BINARY_DIR}/user-config.jam --prefix=<INSTALL_DIR> --with-system --with-filesystem --with-thread --with-chrono --with-date_time install
        BUILD_BYPRODUCTS
            ${BOOST_INSTALL_DIR}/lib/libboost_system.a
            ${BOOST_INSTALL_DIR}/lib/libboost_filesystem.a
            ${BOOST_INSTALL_DIR}/lib/libboost_thread.a
            ${BOOST_INSTALL_DIR}/lib/libboost_chrono.a
            ${BOOST_INSTALL_DIR}/lib/libboost_date_time.a
        INSTALL_COMMAND ""
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${BOOST_INSTALL_DIR})
    set(BOOST_ROOT ${BOOST_INSTALL_DIR} CACHE PATH "" FORCE)
    set(BOOST_INCLUDEDIR ${BOOST_INSTALL_DIR}/include CACHE PATH "" FORCE)
    set(BOOST_LIBRARYDIR ${BOOST_INSTALL_DIR}/lib CACHE PATH "" FORCE)
    set(Boost_NO_SYSTEM_PATHS ON CACHE BOOL "" FORCE)
    set(Boost_USE_STATIC_LIBS ON CACHE BOOL "" FORCE)

    # libcoap
    set(LIBCOAP_INSTALL_DIR ${CMAKE_BINARY_DIR}/libcoap-install)

    set(LIBCOAP_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${LIBCOAP_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_STANDARD=11
        -DCMAKE_C_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
        -DENABLE_DTLS=ON
        -DENABLE_TCP=ON
        -DENABLE_OSCORE=ON
        -DDTLS_BACKEND=openssl
        -DENABLE_EXAMPLES=OFF
        -DENABLE_DOCS=OFF
        -DENABLE_TESTS=OFF
        -DOPENSSL_ROOT_DIR=${OPENSSL_INSTALL_DIR}
        -DOPENSSL_INCLUDE_DIR=${OPENSSL_INSTALL_DIR}/include
        -DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_INSTALL_DIR}/lib/libcrypto.a
        -DOPENSSL_SSL_LIBRARY=${OPENSSL_INSTALL_DIR}/lib/libssl.a
    )
    if(CCACHE_PROGRAM)
        list(APPEND LIBCOAP_CMAKE_ARGS
            -DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_PROGRAM}
            -DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_PROGRAM})
    endif()

    ExternalProject_Add(libcoap-external
        GIT_REPOSITORY https://github.com/obgm/libcoap.git
        GIT_TAG v4.3.5
        GIT_SHALLOW ON
        CMAKE_ARGS ${LIBCOAP_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build .
        BUILD_BYPRODUCTS
            ${LIBCOAP_INSTALL_DIR}/lib/libcoap-3-openssl.a
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
        DEPENDS openssl-external
    )

    list(APPEND CMAKE_PREFIX_PATH ${LIBCOAP_INSTALL_DIR})

    # Detect build system triplet for autotools cross-compilation
    execute_process(
        COMMAND gcc -dumpmachine
        OUTPUT_VARIABLE AUTOTOOLS_BUILD_TRIPLET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NOT AUTOTOOLS_BUILD_TRIPLET)
        set(AUTOTOOLS_BUILD_TRIPLET "x86_64-linux-gnu")
    endif()

    # Get host triplet for cross-compilation (CMAKE_C_COMPILER_TARGET should be set in toolchain file)
    set(AUTOTOOLS_HOST_TRIPLET ${CMAKE_C_COMPILER_TARGET})

    message(STATUS "Autotools build triplet: ${AUTOTOOLS_BUILD_TRIPLET}")
    message(STATUS "Autotools host triplet: ${AUTOTOOLS_HOST_TRIPLET}")

    # libite (dependency of watchdogd)
    set(LIBITE_INSTALL_DIR ${CMAKE_BINARY_DIR}/libite-install)

    if(CCACHE_PROGRAM)
        set(LIBITE_CC "${CCACHE_PROGRAM} ${CMAKE_C_COMPILER}")
    else()
        set(LIBITE_CC "${CMAKE_C_COMPILER}")
    endif()

    ExternalProject_Add(libite-external
        GIT_REPOSITORY https://github.com/troglobit/libite.git
        GIT_TAG v2.6.1
        GIT_SHALLOW ON
        INSTALL_DIR ${LIBITE_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh
            COMMAND ${CMAKE_COMMAND} -E env "CC=${LIBITE_CC}" "PKG_CONFIG_PATH=${LIBITE_INSTALL_DIR}/lib/pkgconfig"
                <SOURCE_DIR>/configure
                    --prefix=<INSTALL_DIR>
                    --build=${AUTOTOOLS_BUILD_TRIPLET}
                    --host=${AUTOTOOLS_HOST_TRIPLET}
                    --enable-static
                    --disable-shared
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${LIBITE_INSTALL_DIR}/lib/libite.a
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${LIBITE_INSTALL_DIR})

    # libuEv (dependency of watchdogd)
    set(LIBUEV_INSTALL_DIR ${CMAKE_BINARY_DIR}/libuev-install)

    if(CCACHE_PROGRAM)
        set(LIBUEV_CC "${CCACHE_PROGRAM} ${CMAKE_C_COMPILER}")
    else()
        set(LIBUEV_CC "${CMAKE_C_COMPILER}")
    endif()

    ExternalProject_Add(libuev-external
        GIT_REPOSITORY https://github.com/troglobit/libuev.git
        GIT_TAG v2.4.1
        GIT_SHALLOW ON
        INSTALL_DIR ${LIBUEV_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh
            COMMAND ${CMAKE_COMMAND} -E env "CC=${LIBUEV_CC}" "PKG_CONFIG_PATH=${LIBUEV_INSTALL_DIR}/lib/pkgconfig"
                <SOURCE_DIR>/configure
                    --prefix=<INSTALL_DIR>
                    --build=${AUTOTOOLS_BUILD_TRIPLET}
                    --host=${AUTOTOOLS_HOST_TRIPLET}
                    --enable-static
                    --disable-shared
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${LIBUEV_INSTALL_DIR}/lib/libuev.a
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${LIBUEV_INSTALL_DIR})

    # libConfuse (dependency of watchdogd)
    set(LIBCONFUSE_INSTALL_DIR ${CMAKE_BINARY_DIR}/libconfuse-install)

    if(CCACHE_PROGRAM)
        set(LIBCONFUSE_CC "${CCACHE_PROGRAM} ${CMAKE_C_COMPILER}")
    else()
        set(LIBCONFUSE_CC "${CMAKE_C_COMPILER}")
    endif()

    ExternalProject_Add(libconfuse-external
        GIT_REPOSITORY https://github.com/libconfuse/libconfuse.git
        GIT_TAG v3.3
        GIT_SHALLOW ON
        INSTALL_DIR ${LIBCONFUSE_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh
            COMMAND ${CMAKE_COMMAND} -E env "CC=${LIBCONFUSE_CC}" "PKG_CONFIG_PATH=${LIBCONFUSE_INSTALL_DIR}/lib/pkgconfig"
                <SOURCE_DIR>/configure
                    --prefix=<INSTALL_DIR>
                    --build=${AUTOTOOLS_BUILD_TRIPLET}
                    --host=${AUTOTOOLS_HOST_TRIPLET}
                    --enable-static
                    --disable-shared
                    --disable-examples
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${LIBCONFUSE_INSTALL_DIR}/lib/libconfuse.a
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${LIBCONFUSE_INSTALL_DIR})

    # watchdogd
    set(WATCHDOGD_INSTALL_DIR ${CMAKE_BINARY_DIR}/watchdogd-install)

    if(CCACHE_PROGRAM)
        set(WATCHDOGD_CC "${CCACHE_PROGRAM} ${CMAKE_C_COMPILER}")
    else()
        set(WATCHDOGD_CC "${CMAKE_C_COMPILER}")
    endif()

    ExternalProject_Add(watchdogd-external
        GIT_REPOSITORY https://github.com/troglobit/watchdogd.git
        GIT_TAG v4.1
        GIT_SHALLOW ON
        INSTALL_DIR ${WATCHDOGD_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh
            COMMAND ${CMAKE_COMMAND} -E env 
                "CC=${WATCHDOGD_CC}"
                "PKG_CONFIG_PATH=${LIBITE_INSTALL_DIR}/lib/pkgconfig:${LIBUEV_INSTALL_DIR}/lib/pkgconfig:${LIBCONFUSE_INSTALL_DIR}/lib/pkgconfig"
                "CFLAGS=-I${LIBITE_INSTALL_DIR}/include -I${LIBUEV_INSTALL_DIR}/include -I${LIBCONFUSE_INSTALL_DIR}/include"
                "LDFLAGS=-L${LIBITE_INSTALL_DIR}/lib -L${LIBUEV_INSTALL_DIR}/lib -L${LIBCONFUSE_INSTALL_DIR}/lib"
                <SOURCE_DIR>/configure
                    --prefix=<INSTALL_DIR>
                    --build=${AUTOTOOLS_BUILD_TRIPLET}
                    --host=${AUTOTOOLS_HOST_TRIPLET}
                    --enable-static
                    --disable-shared
        BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
        BUILD_BYPRODUCTS
            ${WATCHDOGD_INSTALL_DIR}/lib/libwdog.a
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
        DEPENDS libite-external libuev-external libconfuse-external
    )

    list(APPEND CMAKE_PREFIX_PATH ${WATCHDOGD_INSTALL_DIR})
endmacro()

macro(install_alumy_spdlog)
    set(SPDLOG_INSTALL_DIR ${CMAKE_BINARY_DIR}/spdlog-install)

    install(DIRECTORY ${SPDLOG_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_qpcpp)
    set(QPCPP_INSTALL_DIR ${CMAKE_BINARY_DIR}/qpcpp-install)

    install(DIRECTORY ${QPCPP_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_log4qt)
    set(LOG4QT_INSTALL_DIR ${CMAKE_BINARY_DIR}/log4qt-install)

    install(DIRECTORY ${LOG4QT_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_libsndfile)
    set(LIBSNDFILE_INSTALL_DIR ${CMAKE_BINARY_DIR}/libsndfile-install)

    install(DIRECTORY ${LIBSNDFILE_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_yamlcpp)
    set(YAMLCPP_INSTALL_DIR ${CMAKE_BINARY_DIR}/yaml-cpp-install)

    install(DIRECTORY ${YAMLCPP_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_grpc)
    set(GRPC_INSTALL_DIR ${CMAKE_BINARY_DIR}/grpc-install)

    install(DIRECTORY ${GRPC_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_openssl)
    set(OPENSSL_INSTALL_DIR ${CMAKE_BINARY_DIR}/openssl-install)
    
    install(DIRECTORY ${OPENSSL_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_boost)
    set(BOOST_INSTALL_DIR ${CMAKE_BINARY_DIR}/boost-install)

    install(DIRECTORY ${BOOST_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_libcoap)
    set(LIBCOAP_INSTALL_DIR ${CMAKE_BINARY_DIR}/libcoap-install)

    install(DIRECTORY ${LIBCOAP_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_libite)
    set(LIBITE_INSTALL_DIR ${CMAKE_BINARY_DIR}/libite-install)

    install(DIRECTORY ${LIBITE_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_libuev)
    set(LIBUEV_INSTALL_DIR ${CMAKE_BINARY_DIR}/libuev-install)

    install(DIRECTORY ${LIBUEV_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_libconfuse)
    set(LIBCONFUSE_INSTALL_DIR ${CMAKE_BINARY_DIR}/libconfuse-install)

    install(DIRECTORY ${LIBCONFUSE_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_watchdogd)
    set(WATCHDOGD_INSTALL_DIR ${CMAKE_BINARY_DIR}/watchdogd-install)

    install(DIRECTORY ${WATCHDOGD_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS)
endmacro()

macro(install_alumy_dependencies)
    install_alumy_spdlog()
    install_alumy_qpcpp()
    install_alumy_log4qt()
    install_alumy_libsndfile()
    install_alumy_yamlcpp()
    install_alumy_grpc()
    install_alumy_openssl()
    install_alumy_boost()
    install_alumy_libcoap()
    install_alumy_libite()
    install_alumy_libuev()
    install_alumy_libconfuse()
    install_alumy_watchdogd()
endmacro()

macro(add_alumy_dependencies target)
    add_dependencies(${target} 
        spdlog-external 
        qpcpp-external 
        log4qt-external 
        libsndfile-external 
        yaml-cpp-external 
        grpc-external 
        openssl-external 
        boost-external 
        libcoap-external
        libite-external
        libuev-external
        libconfuse-external
        watchdogd-external
    )
endmacro()

macro(link_alumy_dependencies target)
    set(SPDLOG_INSTALL_DIR ${CMAKE_BINARY_DIR}/spdlog-install)
    set(QPCPP_INSTALL_DIR ${CMAKE_BINARY_DIR}/qpcpp-install)
    set(LOG4QT_INSTALL_DIR ${CMAKE_BINARY_DIR}/log4qt-install)
    set(LIBSNDFILE_INSTALL_DIR ${CMAKE_BINARY_DIR}/libsndfile-install)
    set(YAMLCPP_INSTALL_DIR ${CMAKE_BINARY_DIR}/yaml-cpp-install)
    set(GRPC_INSTALL_DIR ${CMAKE_BINARY_DIR}/grpc-install)
    set(OPENSSL_INSTALL_DIR ${CMAKE_BINARY_DIR}/openssl-install)
    set(BOOST_INSTALL_DIR ${CMAKE_BINARY_DIR}/boost-install)
    set(LIBCOAP_INSTALL_DIR ${CMAKE_BINARY_DIR}/libcoap-install)
    set(LIBITE_INSTALL_DIR ${CMAKE_BINARY_DIR}/libite-install)
    set(LIBUEV_INSTALL_DIR ${CMAKE_BINARY_DIR}/libuev-install)
    set(LIBCONFUSE_INSTALL_DIR ${CMAKE_BINARY_DIR}/libconfuse-install)
    set(WATCHDOGD_INSTALL_DIR ${CMAKE_BINARY_DIR}/watchdogd-install)

    target_include_directories(${target} PUBLIC
        $<BUILD_INTERFACE:${SPDLOG_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${QPCPP_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${LOG4QT_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${LIBSNDFILE_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${YAMLCPP_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${GRPC_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${OPENSSL_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${BOOST_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${LIBCOAP_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${LIBITE_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${LIBUEV_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${LIBCONFUSE_INSTALL_DIR}/include>
        $<BUILD_INTERFACE:${WATCHDOGD_INSTALL_DIR}/include>
        $<INSTALL_INTERFACE:include>
    )

    target_link_directories(${target} PUBLIC
        $<BUILD_INTERFACE:${SPDLOG_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${QPCPP_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${LOG4QT_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${LIBSNDFILE_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${YAMLCPP_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${GRPC_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${OPENSSL_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${BOOST_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${LIBCOAP_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${LIBITE_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${LIBUEV_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${LIBCONFUSE_INSTALL_DIR}/lib>
        $<BUILD_INTERFACE:${WATCHDOGD_INSTALL_DIR}/lib>
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
        grpc++
        grpc
        gpr
        address_sorting
        upb
        coap-3-openssl
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
