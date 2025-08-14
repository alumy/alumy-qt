# in case SVN is not available, default to 0
set(SVN_REVISION 0)

# Determine this module's root directory regardless of superbuild context
get_filename_component(ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

# find svn revision when building from an SVN working copy of this module
if(EXISTS "${ROOT_DIR}/.svn/")
    find_package(Subversion)

    if(SUBVERSION_FOUND)
        Subversion_WC_INFO(${ROOT_DIR} PROJ)
        set(SVN_REVISION ${PROJ_WC_REVISION})
    endif()
endif()

message(STATUS "SVN revision is ${SVN_REVISION}")

# generate header from template within this module's include directory
configure_file(
    ${ROOT_DIR}/include/alumy/svn_revision.h.in
    ${ROOT_DIR}/include/alumy/svn_revision.h
    @ONLY)
