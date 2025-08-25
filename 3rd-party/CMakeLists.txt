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

target_include_directories(qtsingleapplication PUBLIC ${QTSINGLEAPP_SRC_DIR})

install(TARGETS qtsingleapplication
    DESTINATION "${CMAKE_INSTALL_LIBDIR}")

install(FILES 
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.h
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.h
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

install_alumy_grpc()

target_link_libraries(${target} INTERFACE qtsingleapplication)
