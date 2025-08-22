include(ExternalProject)

macro(configure_alumy_dependencies)
    set(SPDLOG_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/3rd-party/spdlog-build")
    set(SPDLOG_INSTALL_DIR "${SPDLOG_PREFIX}/install")
    set(SPDLOG_INCLUDE_DIR "${SPDLOG_INSTALL_DIR}/include")
    set(SPDLOG_LIB_DIR "${SPDLOG_INSTALL_DIR}/lib")

    set(SPDLOG_CMAKE_ARGS
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_INSTALL_PREFIX=${SPDLOG_INSTALL_DIR}
        -DSPDLOG_ENABLE_PCH=ON
        -DSPDLOG_BUILD_SHARED=OFF
        -DSPDLOG_BUILD_TESTS=OFF
        -DSPDLOG_BUILD_BENCH=OFF
        -DBUILD_SHARED_LIBS=OFF
    )

    ExternalProject_Add(spdlog_proj
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG v1.15.3
        GIT_SHALLOW ON
        GIT_PROGRESS ON
        UPDATE_DISCONNECTED ON
        PREFIX ${SPDLOG_PREFIX}
        CMAKE_ARGS ${SPDLOG_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build . --parallel ${CMAKE_BUILD_PARALLEL_LEVEL}
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        STEP_TARGETS download configure build install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        LOG_OUTPUT_ON_FAILURE ON
        USES_TERMINAL_DOWNLOAD ON
        USES_TERMINAL_CONFIGURE ON
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    add_library(spdlog::spdlog STATIC IMPORTED)
    set_target_properties(spdlog::spdlog PROPERTIES
        IMPORTED_LOCATION "${SPDLOG_LIB_DIR}/libspdlog.a"
        INTERFACE_INCLUDE_DIRECTORIES "${SPDLOG_INCLUDE_DIR}"
    )
    add_dependencies(spdlog::spdlog spdlog_proj)

    set(QPCPP_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/3rd-party/qpcpp-build")
    set(QPCPP_INSTALL_DIR "${QPCPP_PREFIX}/install")
    set(QPCPP_INCLUDE_DIR "${QPCPP_INSTALL_DIR}/include")
    set(QPCPP_LIB_DIR "${QPCPP_INSTALL_DIR}/lib")

    set(QPCPP_CMAKE_ARGS
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_INSTALL_PREFIX=${QPCPP_INSTALL_DIR}
        -DCMAKE_CXX_STANDARD=14
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCMAKE_CXX_EXTENSIONS=OFF
        -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
        -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
        -DBUILD_SHARED_LIBS=OFF
        -DQPCPP_CFG_KERNEL=qv
        -DQPCPP_CFG_PORT=posix
        -DQPCPP_CFG_GUI=OFF
        -DQPCPP_CFG_UNIT_TEST=OFF
        -DQPCPP_CFG_VERBOSE=OFF
    )

    ExternalProject_Add(qpcpp_proj
        GIT_REPOSITORY https://github.com/QuantumLeaps/qpcpp.git
        GIT_TAG v7.3.4
        GIT_SHALLOW ON
        GIT_PROGRESS ON
        UPDATE_DISCONNECTED ON
        PREFIX ${QPCPP_PREFIX}
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/cmake/qpcpp_force_cxx.cmake <SOURCE_DIR>/force_cxx.cmake
            COMMAND sed -i "1i include(force_cxx.cmake)" <SOURCE_DIR>/CMakeLists.txt
        CMAKE_ARGS ${QPCPP_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build . --parallel ${CMAKE_BUILD_PARALLEL_LEVEL}
        INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${QPCPP_INSTALL_DIR}/lib ${QPCPP_INSTALL_DIR}/include
            COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libqpcpp.a ${QPCPP_INSTALL_DIR}/lib/
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include ${QPCPP_INSTALL_DIR}/include
        STEP_TARGETS download configure build install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        LOG_OUTPUT_ON_FAILURE ON
        USES_TERMINAL_DOWNLOAD ON
        USES_TERMINAL_CONFIGURE ON
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    add_library(qpcpp STATIC IMPORTED)
    set_target_properties(qpcpp PROPERTIES
        IMPORTED_LOCATION "${QPCPP_LIB_DIR}/libqpcpp.a"
        INTERFACE_INCLUDE_DIRECTORIES "${QPCPP_INCLUDE_DIR}"
    )
    add_dependencies(qpcpp qpcpp_proj)

    set(LOG4QT_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/3rd-party/log4qt-build")
    set(LOG4QT_INSTALL_DIR "${LOG4QT_PREFIX}/install")
    set(LOG4QT_INCLUDE_DIR "${LOG4QT_INSTALL_DIR}/include")
    set(LOG4QT_LIB_DIR "${LOG4QT_INSTALL_DIR}/lib")

    set(LOG4QT_CMAKE_ARGS
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_INSTALL_PREFIX=${LOG4QT_INSTALL_DIR}
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_STATIC_LOG4CXX_LIB=ON
        -DBUILD_WITH_DB_LOGGING=OFF
        -DBUILD_WITH_TELNET_LOGGING=ON
        -DBUILD_WITH_DOCS=OFF
    )

    ExternalProject_Add(log4qt_proj
        GIT_REPOSITORY https://github.com/MEONMedical/Log4Qt.git
        GIT_TAG v1.5.1
        GIT_SHALLOW ON
        GIT_PROGRESS ON
        UPDATE_DISCONNECTED ON
        PREFIX ${LOG4QT_PREFIX}
        CMAKE_ARGS ${LOG4QT_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build . --parallel ${CMAKE_BUILD_PARALLEL_LEVEL}
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        STEP_TARGETS download configure build install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        LOG_OUTPUT_ON_FAILURE ON
        USES_TERMINAL_DOWNLOAD ON
        USES_TERMINAL_CONFIGURE ON
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    add_library(log4qt STATIC IMPORTED)
    set_target_properties(log4qt PROPERTIES
        IMPORTED_LOCATION "${LOG4QT_LIB_DIR}/liblog4qt.a"
        INTERFACE_INCLUDE_DIRECTORIES "${LOG4QT_INCLUDE_DIR}"
    )
    add_dependencies(log4qt log4qt_proj)

    set(LIBSNDFILE_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/3rd-party/libsndfile-build")
    set(LIBSNDFILE_INSTALL_DIR "${LIBSNDFILE_PREFIX}/install")
    set(LIBSNDFILE_INCLUDE_DIR "${LIBSNDFILE_INSTALL_DIR}/include")
    set(LIBSNDFILE_LIB_DIR "${LIBSNDFILE_INSTALL_DIR}/lib")

    set(LIBSNDFILE_CMAKE_ARGS
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_INSTALL_PREFIX=${LIBSNDFILE_INSTALL_DIR}
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_PROGRAMS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_EXTERNAL_LIBS=ON
        -DENABLE_MPEG=OFF
    )

    ExternalProject_Add(libsndfile_proj
        GIT_REPOSITORY https://github.com/libsndfile/libsndfile.git
        GIT_TAG 1.2.2
        GIT_SHALLOW ON
        GIT_PROGRESS ON
        UPDATE_DISCONNECTED ON
        PREFIX ${LIBSNDFILE_PREFIX}
        CMAKE_ARGS ${LIBSNDFILE_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build . --parallel ${CMAKE_BUILD_PARALLEL_LEVEL}
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        STEP_TARGETS download configure build install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        LOG_OUTPUT_ON_FAILURE ON
        USES_TERMINAL_DOWNLOAD ON
        USES_TERMINAL_CONFIGURE ON
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    add_library(SndFile::sndfile STATIC IMPORTED)
    set_target_properties(SndFile::sndfile PROPERTIES
        IMPORTED_LOCATION "${LIBSNDFILE_LIB_DIR}/libsndfile.a"
        INTERFACE_INCLUDE_DIRECTORIES "${LIBSNDFILE_INCLUDE_DIR}"
    )
    add_dependencies(SndFile::sndfile libsndfile_proj)

    set(GRPC_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/3rd-party/grpc-build")
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

    ExternalProject_Add(grpc_proj
        GIT_REPOSITORY https://github.com/grpc/grpc.git
        GIT_TAG v1.48.2
        GIT_SUBMODULES_RECURSE ON
        GIT_SHALLOW ON
        GIT_PROGRESS ON
        UPDATE_DISCONNECTED ON
        PREFIX ${GRPC_PREFIX}
        CMAKE_ARGS ${GRPC_CMAKE_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build . --parallel ${CMAKE_BUILD_PARALLEL_LEVEL}
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        STEP_TARGETS download configure build install
        LOG_DOWNLOAD OFF
        LOG_CONFIGURE OFF
        LOG_BUILD OFF
        LOG_INSTALL OFF
        LOG_OUTPUT_ON_FAILURE ON
        USES_TERMINAL_DOWNLOAD ON
        USES_TERMINAL_CONFIGURE ON
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
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

    add_dependencies(grpc++ grpc_proj)
    add_dependencies(grpc grpc_proj)
    add_dependencies(gpr grpc_proj)
    add_dependencies(address_sorting grpc_proj)
    add_dependencies(upb grpc_proj)
    add_dependencies(protobuf::libprotobuf grpc_proj)
    add_dependencies(re2::re2 grpc_proj)
    add_dependencies(c-ares::cares grpc_proj)

    add_executable(grpc_cpp_plugin IMPORTED)
    set_target_properties(grpc_cpp_plugin PROPERTIES
        IMPORTED_LOCATION "${GRPC_INSTALL_DIR}/bin/grpc_cpp_plugin"
    )
    add_dependencies(grpc_cpp_plugin grpc_proj)

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
