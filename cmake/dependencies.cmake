include(FetchContent)
include(ExternalProject)

macro(configure_alumy_dependencies)
    if(NOT TARGET spdlog AND NOT TARGET spdlog::spdlog)
        set(SPDLOG_ENABLE_PCH ON CACHE BOOL "" FORCE)
        set(SPDLOG_BUILD_SHARED OFF CACHE BOOL "" FORCE)
        set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
        set(SPDLOG_BUILD_BENCH OFF CACHE BOOL "" FORCE)
        set(SPDLOG_INSTALL ON CACHE BOOL "" FORCE)

        set(_ALUMY_ORIGINAL_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
        set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

        FetchContent_Declare(spdlog
            GIT_REPOSITORY https://github.com/gabime/spdlog.git
            GIT_TAG v1.15.3
            GIT_SHALLOW ON
        )
        FetchContent_MakeAvailable(spdlog)
    endif()

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

    if(NOT TARGET log4qt)
        set(BUILD_STATIC_LOG4CXX_LIB ON CACHE BOOL "" FORCE)
        set(BUILD_WITH_DB_LOGGING OFF CACHE BOOL "" FORCE)
        set(BUILD_WITH_TELNET_LOGGING ON CACHE BOOL "" FORCE)
        set(BUILD_WITH_DOCS OFF CACHE BOOL "" FORCE)
        set(LOG4QT_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
        set(LOG4QT_BUILD_TESTS OFF CACHE BOOL "" FORCE)

        FetchContent_Declare(log4qt
            GIT_REPOSITORY https://github.com/MEONMedical/Log4Qt.git
            GIT_TAG v1.5.1
            GIT_SHALLOW ON
        )
        FetchContent_MakeAvailable(log4qt)
    endif()

    if(NOT TARGET SndFile::sndfile)
        set(BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)
        set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
        set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
        set(ENABLE_EXTERNAL_LIBS ON CACHE BOOL "" FORCE)
        set(ENABLE_MPEG OFF CACHE BOOL "" FORCE)
        set(ENABLE_INSTALL ON CACHE BOOL "" FORCE)

        FetchContent_Declare(libsndfile
            GIT_REPOSITORY https://github.com/libsndfile/libsndfile.git
            GIT_TAG 1.2.2
            GIT_SHALLOW ON
        )

        FetchContent_MakeAvailable(libsndfile)

        if(TARGET sndfile)
            target_compile_options(sndfile PRIVATE -Wno-format-truncation)
        endif()
    endif()

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

    set(OPENSSL_CONFIGURE_COMMAND 
        ${CMAKE_COMMAND} -E env CC=${CMAKE_C_COMPILER}
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

    set(BOOST_INSTALL_DIR ${CMAKE_BINARY_DIR}/boost-install)

    set(BOOST_B2_OPTIONS variant=release link=static runtime-link=static threading=multi cxxstd=11)

    include(ProcessorCount)
    ProcessorCount(N_CORES)
    if(NOT N_CORES EQUAL 0)
        set(BOOST_PARALLEL_JOBS ${N_CORES})
    else()
        set(BOOST_PARALLEL_JOBS 4)
    endif()

    file(WRITE ${CMAKE_BINARY_DIR}/user-config.jam 
        "using gcc : : ${CMAKE_CXX_COMPILER} ;\n"
    )

    ExternalProject_Add(boost-external
        GIT_REPOSITORY https://github.com/boostorg/boost.git
        GIT_TAG boost-1.75.0
        GIT_SHALLOW ON
        GIT_SUBMODULES_RECURSE ON
        INSTALL_DIR ${BOOST_INSTALL_DIR}
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./bootstrap.sh --prefix=<INSTALL_DIR>
        BUILD_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./b2 -j${BOOST_PARALLEL_JOBS} ${BOOST_B2_OPTIONS} --user-config=${CMAKE_BINARY_DIR}/user-config.jam --prefix=<INSTALL_DIR> headers
            COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./b2 -j${BOOST_PARALLEL_JOBS} ${BOOST_B2_OPTIONS} --user-config=${CMAKE_BINARY_DIR}/user-config.jam --prefix=<INSTALL_DIR> --with-system --with-filesystem --with-thread --with-chrono --with-date_time install
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

    if(DEFINED _ALUMY_ORIGINAL_BUILD_SHARED_LIBS)
        set(BUILD_SHARED_LIBS ${_ALUMY_ORIGINAL_BUILD_SHARED_LIBS} CACHE BOOL "" FORCE)
        unset(_ALUMY_ORIGINAL_BUILD_SHARED_LIBS)
    endif()
endmacro()

macro(install_qpcpp)
    set(QPCPP_INSTALL_DIR ${CMAKE_BINARY_DIR}/qpcpp-install)

    install(DIRECTORY ${QPCPP_INSTALL_DIR}/
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

macro(install_alumy_fetchcontent_dependencies)
    if(TARGET spdlog)
        install(TARGETS spdlog
            EXPORT alumy-targets
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        )
        install(DIRECTORY ${spdlog_SOURCE_DIR}/include/
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
            FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
        )
    endif()

    if(TARGET log4qt)
        install(TARGETS log4qt
            EXPORT alumy-targets
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        )
        if(log4qt_SOURCE_DIR)
            install(DIRECTORY ${log4qt_SOURCE_DIR}/src/
                DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/log4qt
                FILES_MATCHING PATTERN "*.h"
            )
        endif()
    endif()

    if(TARGET SndFile::sndfile)
        get_target_property(sndfile_actual_target SndFile::sndfile ALIASED_TARGET)
        if(sndfile_actual_target)
            set(sndfile_target ${sndfile_actual_target})
        else()
            set(sndfile_target SndFile::sndfile)
        endif()
        
        install(TARGETS ${sndfile_target}
            EXPORT alumy-targets
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        )
    endif()
endmacro()

macro(install_alumy_dependencies)
    install_qpcpp()
    install_alumy_grpc()
    install_alumy_openssl()
    install_alumy_boost()
    install_alumy_fetchcontent_dependencies()
endmacro()

macro(add_alumy_dependencies target)
    add_dependencies(${target} qpcpp-external grpc-external openssl-external boost-external)
endmacro()

macro(link_alumy_dependencies target)
    target_link_libraries(${target} PUBLIC
        boost_system
        boost_filesystem
        boost_thread
        boost_chrono
        boost_date_time
        log4qt 
        SndFile::sndfile
        spdlog
        qpcpp
        grpc++
        grpc
        gpr
        address_sorting
        upb
        ssl 
        crypto
        pthread
        dl
        m)
endmacro()
