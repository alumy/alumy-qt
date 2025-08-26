set(target protobuf-c)

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR} ${target}_src)

add_library(${target} OBJECT ${${target}_src})
target_link_libraries(${target} PRIVATE 3rd-party)
target_compile_options(${target} PRIVATE -Wno-unused-but-set-variable)
