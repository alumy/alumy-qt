if(DEFINED ENV{GITHUB_MIRROR})
    set(GITHUB_BASE_URL "$ENV{GITHUB_MIRROR}")
else()
    set(GITHUB_BASE_URL "https://github.com")
endif()

message(STATUS "Using GitHub mirror: ${GITHUB_BASE_URL}")
