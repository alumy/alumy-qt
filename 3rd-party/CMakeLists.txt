set(target alumy-3rd-party)

add_library(${target} INTERFACE)

include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/dependencies.cmake)
configure_alumy_dependencies()

link_alumy_dependencies(${target})
