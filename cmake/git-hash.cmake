# in case Git is not available, we default to "unknown"
set(GIT_HASH "unknown")

# Determine this module's root directory regardless of superbuild context
get_filename_component(ALUMY_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

# find Git and if available set GIT_HASH variable
find_package(Git QUIET)

if(GIT_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%h
        WORKING_DIRECTORY ${ALUMY_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET)
endif()

message(STATUS "Git hash is ${GIT_HASH}")

# generate file from template within this module's include directory
configure_file(
    ${ALUMY_SOURCE_DIR}/include/alumy/git_hash.h.in
    ${ALUMY_SOURCE_DIR}/include/alumy/git_hash.h
    @ONLY)
