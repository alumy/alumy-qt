include(FetchContent)
include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/cal_parallel_level.cmake)

macro(configure_alumy_dependencies)
    # Configure spdlog
    set(SPDLOG_ENABLE_PCH ON CACHE BOOL "" FORCE)
    set(SPDLOG_BUILD_SHARED OFF CACHE BOOL "" FORCE)
    set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
    set(SPDLOG_BUILD_BENCH OFF CACHE BOOL "" FORCE)
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

    FetchContent_Declare(spdlog
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG v1.15.3
        GIT_SHALLOW ON
    )
    FetchContent_MakeAvailable(spdlog)

    set(QPCPP_CXX_STANDARD 11 CACHE STRING "" FORCE)
    set(QPCPP_CFG_KERNEL qv CACHE STRING "" FORCE)
    set(QPCPP_CFG_PORT posix CACHE STRING "" FORCE)
    set(QPCPP_CFG_GUI OFF CACHE BOOL "" FORCE)
    set(QPCPP_CFG_UNIT_TEST OFF CACHE BOOL "" FORCE)
    set(QPCPP_CFG_VERBOSE OFF CACHE BOOL "" FORCE)

    FetchContent_Declare(qpcpp
        GIT_REPOSITORY https://github.com/QuantumLeaps/qpcpp.git
        GIT_TAG v7.3.4
        GIT_SHALLOW ON
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/cmake/qpcpp_force_cxx.cmake <SOURCE_DIR>/force_cxx.cmake
            COMMAND sed -i "1i include(force_cxx.cmake)" <SOURCE_DIR>/CMakeLists.txt
    )

    # Configure log4qt
    set(BUILD_STATIC_LOG4CXX_LIB ON CACHE BOOL "" FORCE)
    set(BUILD_WITH_DB_LOGGING OFF CACHE BOOL "" FORCE)
    set(BUILD_WITH_TELNET_LOGGING ON CACHE BOOL "" FORCE)
    set(BUILD_WITH_DOCS OFF CACHE BOOL "" FORCE)

    FetchContent_Declare(log4qt
        GIT_REPOSITORY https://github.com/MEONMedical/Log4Qt.git
        GIT_TAG v1.5.1
        GIT_SHALLOW ON
    )
    FetchContent_MakeAvailable(log4qt)

    # Configure libsndfile
    set(BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)
    set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
    set(ENABLE_EXTERNAL_LIBS ON CACHE BOOL "" FORCE)
    set(ENABLE_MPEG OFF CACHE BOOL "" FORCE)

    FetchContent_Declare(libsndfile
        GIT_REPOSITORY https://github.com/libsndfile/libsndfile.git
        GIT_TAG 1.2.2
        GIT_SHALLOW ON
    )
    FetchContent_MakeAvailable(libsndfile)

    set(GRPC_INSTALL_DIR ${CMAKE_BINARY_DIR}/grpc-install)

    set(GRPC_CMAKE_ARGS
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
        -DgRPC_BUILD_GRPC_REFLECTION=OFF
        -DgRPC_ABSL_PROVIDER=module
        -DgRPC_CARES_PROVIDER=module
        -DgRPC_PROTOBUF_PROVIDER=module
        -DgRPC_RE2_PROVIDER=module
        -DgRPC_SSL_PROVIDER=none
        -DgRPC_ZLIB_PROVIDER=module
        -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON
        -DgRPC_BUILD_CODEGEN=ON
        -DgRPC_INSTALL=ON
        -DABSL_BUILD_TESTING=OFF
        -DABSL_PROPAGATE_CXX_STD=ON
        -DABSL_BUILD_MONOLITHIC_SHARED_LIBS=OFF
        -DgRPC_BACKWARDS_COMPATIBILITY_MODE=OFF
        -DgRPC_BUILD_GRPC_GOOGLE_CLOUD_CPP_PLUGIN=OFF
    )
    
    ExternalProject_Add(grpc-external
        GIT_REPOSITORY https://github.com/grpc/grpc.git
        GIT_TAG v1.46.7
        GIT_SUBMODULES_RECURSE ON
        GIT_SHALLOW ON
        CMAKE_ARGS ${GRPC_CMAKE_ARGS}
        BUILD_BYPRODUCTS 
            ${GRPC_INSTALL_DIR}/lib/libgrpc++.a
            ${GRPC_INSTALL_DIR}/lib/libgrpc.a
            ${GRPC_INSTALL_DIR}/lib/libgpr.a
            ${GRPC_INSTALL_DIR}/lib/libaddress_sorting.a
            ${GRPC_INSTALL_DIR}/lib/libupb.a
            ${GRPC_INSTALL_DIR}/bin/grpc_cpp_plugin
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
    )

    list(APPEND CMAKE_PREFIX_PATH ${GRPC_INSTALL_DIR})
endmacro()

macro(install_alumy_grpc)
    set(GRPC_INSTALL_DIR ${CMAKE_BINARY_DIR}/grpc-install)

    install(DIRECTORY ${GRPC_INSTALL_DIR}/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS
        FILES_MATCHING 
        PATTERN "*"
        PATTERN "*.cmake" EXCLUDE)
endmacro()

macro(link_alumy_dependencies target_name)
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)
    find_package(gRPC QUIET)
    
    if(gRPC_FOUND)
        target_link_libraries(${target_name} INTERFACE 
            spdlog::spdlog 
            qpcpp 
            log4qt 
            SndFile::sndfile 
            gRPC::grpc++
        )
        add_dependencies(${target_name} grpc-external)
    else()
        message(WARNING "gRPC not found, linking without gRPC support")
        target_link_libraries(${target_name} INTERFACE 
            spdlog::spdlog 
            qpcpp 
            log4qt 
            SndFile::sndfile
        )
    endif()
endmacro()
