include(FetchContent)
include(ExternalProject)

macro(configure_alumy_dependencies)
    # Only configure dependencies if they haven't been configured already
    if(NOT TARGET spdlog AND NOT TARGET spdlog::spdlog)
        set(SPDLOG_ENABLE_PCH ON CACHE BOOL "" FORCE)
        set(SPDLOG_BUILD_SHARED OFF CACHE BOOL "" FORCE)
        set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
        set(SPDLOG_BUILD_BENCH OFF CACHE BOOL "" FORCE)
        set(SPDLOG_INSTALL ON CACHE BOOL "" FORCE)
        
        # Save current BUILD_SHARED_LIBS value
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
        -DCMAKE_INSTALL_PREFIX=${QPCPP_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_SHARED_LIBS=OFF
        -DQPCPP_CXX_STANDARD=11
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
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD OFF
        LOG_INSTALL ON
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${QPCPP_INSTALL_DIR})

    if(NOT TARGET log4qt)
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
    endif()

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
        -DgRPC_BUILD_GRPC_GOOGLE_CLOUD_CPP_PLUGIN=OFF
        -DgRPC_ABSL_PROVIDER=module
        -DgRPC_CARES_PROVIDER=module
        -DgRPC_PROTOBUF_PROVIDER=module
        -DgRPC_RE2_PROVIDER=module
        -DgRPC_SSL_PROVIDER=none
        -DgRPC_ZLIB_PROVIDER=module
        -DgRPC_BENCHMARK_PROVIDER=none
        -DgRPC_UPB_PROVIDER=module
        -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON
        -DgRPC_BUILD_CODEGEN=ON
        -DgRPC_INSTALL=ON
        -DgRPC_BACKWARDS_COMPATIBILITY_MODE=OFF
        -DABSL_BUILD_TESTING=OFF
        -DABSL_PROPAGATE_CXX_STD=ON
        -DABSL_BUILD_MONOLITHIC_SHARED_LIBS=OFF
        -DABSL_ENABLE_INSTALL=ON
        -DABSL_BUILD_DLL=OFF
        -Dprotobuf_BUILD_TESTS=OFF
        -Dprotobuf_BUILD_EXAMPLES=OFF
        -Dprotobuf_WITH_ZLIB=OFF
        -Dprotobuf_BUILD_SHARED_LIBS=OFF
        -DRE2_BUILD_TESTING=OFF
        -DCARES_STATIC=ON
        -DCARES_SHARED=OFF
        -DCARES_BUILD_TESTS=OFF
        -DCARES_BUILD_TOOLS=OFF
        -DZLIB_BUILD_EXAMPLES=OFF
        -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF
        -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF
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
            ${GRPC_INSTALL_DIR}/bin/grpc_cpp_plugin
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD OFF
        LOG_INSTALL ON
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )

    list(APPEND CMAKE_PREFIX_PATH ${GRPC_INSTALL_DIR})

    if(DEFINED _ALUMY_ORIGINAL_BUILD_SHARED_LIBS)
        set(BUILD_SHARED_LIBS ${_ALUMY_ORIGINAL_BUILD_SHARED_LIBS} CACHE BOOL "" FORCE)
        unset(_ALUMY_ORIGINAL_BUILD_SHARED_LIBS)
    endif()
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

    set(QPCPP_INSTALL_DIR ${CMAKE_BINARY_DIR}/qpcpp-install)
    if(EXISTS ${QPCPP_INSTALL_DIR})
        install(DIRECTORY ${QPCPP_INSTALL_DIR}/
            DESTINATION "."
            USE_SOURCE_PERMISSIONS
            FILES_MATCHING 
            PATTERN "*"
            PATTERN "*.cmake" EXCLUDE
        )
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
    install_alumy_grpc()
    install_alumy_fetchcontent_dependencies()
endmacro()

macro(link_alumy_dependencies target_name)
    set(QPCPP_INSTALL_DIR ${CMAKE_BINARY_DIR}/qpcpp-install)
    
    add_library(qpcpp STATIC IMPORTED)
    set_target_properties(qpcpp PROPERTIES
        IMPORTED_LOCATION ${QPCPP_INSTALL_DIR}/lib/libqpcpp.a
        INTERFACE_INCLUDE_DIRECTORIES "${QPCPP_INSTALL_DIR}/include"
    )
    add_dependencies(qpcpp qpcpp-external)

    target_link_libraries(${target_name} INTERFACE 
        spdlog::spdlog 
        qpcpp 
        log4qt 
        SndFile::sndfile
    )
    
    set(GRPC_INSTALL_DIR ${CMAKE_BINARY_DIR}/grpc-install)
    
    add_library(grpc++ STATIC IMPORTED)
    set_target_properties(grpc++ PROPERTIES
        IMPORTED_LOCATION ${GRPC_INSTALL_DIR}/lib/libgrpc++.a
        INTERFACE_INCLUDE_DIRECTORIES ${GRPC_INSTALL_DIR}/include
    )
    
    add_library(grpc STATIC IMPORTED)
    set_target_properties(grpc PROPERTIES
        IMPORTED_LOCATION ${GRPC_INSTALL_DIR}/lib/libgrpc.a
        INTERFACE_INCLUDE_DIRECTORIES ${GRPC_INSTALL_DIR}/include
    )
    
    add_library(gpr STATIC IMPORTED)
    set_target_properties(gpr PROPERTIES
        IMPORTED_LOCATION ${GRPC_INSTALL_DIR}/lib/libgpr.a
    )
    
    add_library(address_sorting STATIC IMPORTED)
    set_target_properties(address_sorting PROPERTIES
        IMPORTED_LOCATION ${GRPC_INSTALL_DIR}/lib/libaddress_sorting.a
    )
    
    add_library(upb STATIC IMPORTED)
    set_target_properties(upb PROPERTIES
        IMPORTED_LOCATION ${GRPC_INSTALL_DIR}/lib/libupb.a
    )
    
    target_link_libraries(${target_name} INTERFACE grpc++ grpc gpr address_sorting upb)
    
    add_dependencies(${target_name} grpc-external qpcpp-external)
    add_dependencies(grpc++ grpc-external)
    add_dependencies(grpc grpc-external)
    add_dependencies(gpr grpc-external)
    add_dependencies(address_sorting grpc-external)
    add_dependencies(upb grpc-external)
endmacro()
