# in case SVN is not available, default to 0
set(SVN_REVISION 0)

# Determine this module's root directory regardless of superbuild context
get_filename_component(ALUMY_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

message(STATUS "ALUMY_SOURCE_DIR: ${ALUMY_SOURCE_DIR}")

# find svn revision when building from an SVN working copy of this module
if(EXISTS "${ALUMY_SOURCE_DIR}/.svn/")
    find_package(Subversion)

    if(SUBVERSION_FOUND)
        Subversion_WC_INFO(${ALUMY_SOURCE_DIR} PROJ)
        set(SVN_REVISION ${PROJ_WC_REVISION})
    endif()
endif()

message(STATUS "SVN revision is ${SVN_REVISION}")

# generate header from template within this module's include directory
configure_file(
    ${ALUMY_SOURCE_DIR}/include/alumy/svn_revision.h.in
    ${ALUMY_SOURCE_DIR}/include/alumy/svn_revision.h
    @ONLY)
