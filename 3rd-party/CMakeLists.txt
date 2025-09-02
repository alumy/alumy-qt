set(target 3rd-party)

include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/dependencies.cmake)

set(QTSINGLEAPP_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/qt-solutions/qtsingleapplication/src)

set(${target}_src 
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.cpp
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.h
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.cpp
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.h
)

add_library(${target} OBJECT ${${target}_src})

target_include_directories(${target} PUBLIC 
    $<BUILD_INTERFACE:${QTSINGLEAPP_SRC_DIR}>
    $<INSTALL_INTERFACE:include>
)

target_link_libraries(${target} PUBLIC
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Network
)

configure_alumy_dependencies()

add_alumy_dependencies(${target})

link_alumy_dependencies(${target})

install_alumy_dependencies()

target_include_directories(${target} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
    $<INSTALL_INTERFACE:include>
)

install(FILES 
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.h
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.h
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

install(TARGETS ${target}
    EXPORT alumy-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
