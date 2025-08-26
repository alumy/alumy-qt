set(target alumy-3rd-party)

add_library(${target} INTERFACE)

include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/dependencies.cmake)
configure_alumy_dependencies()

add_dependencies(${target} grpc-external)

link_alumy_dependencies(${target})

# Add QtSingleApplication library
set(QTSINGLEAPP_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/qt-solutions/qtsingleapplication/src)

add_library(qtsingleapplication STATIC
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.cpp
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.h
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.cpp
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.h
)

target_include_directories(qtsingleapplication PUBLIC 
    $<BUILD_INTERFACE:${QTSINGLEAPP_SRC_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Install qtsingleapplication with proper export
install(TARGETS qtsingleapplication
    EXPORT alumy-targets
    DESTINATION "${CMAKE_INSTALL_LIBDIR}")

install(FILES 
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.h
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.h
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

# Install all dependencies
install_alumy_dependencies()

target_link_libraries(${target} INTERFACE qtsingleapplication)

# Set up the interface target properties for proper export
target_include_directories(${target} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
    $<INSTALL_INTERFACE:include>
)
