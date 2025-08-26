set(target net)

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR} ${target}_src)

add_library(${target} OBJECT ${${target}_src})
target_link_libraries(${target} PUBLIC 3rd-party)
