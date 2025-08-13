get_filename_component(toolchain ${CMAKE_TOOLCHAIN_FILE} NAME ABSOLUTE)
get_filename_component(toolchain_we ${CMAKE_TOOLCHAIN_FILE} NAME_WE ABSOLUTE)

set(flags_file ${PROJECT_SOURCE_DIR}/cmake/toolchain/${toolchain_we}-flags.cmake CACHE STRING "" FORCE)

if((NOT EXISTS ${flags_file}) OR (IS_DIRECTORY ${flags_file}))
	MESSAGE(STATUS  "${flags_file} is not exists")
else()
	include(${flags_file})
endif()
