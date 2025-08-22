function(cal_parallel_level OUTPUT_VAR)
    set(options "")
    set(oneValueArgs MEMORY_PER_JOB_MB MEMORY_USAGE_PERCENT MIN_LEVEL MAX_LEVEL)
    set(multiValueArgs "")
    cmake_parse_arguments(CALC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT CALC_MEMORY_PER_JOB_MB)
        set(CALC_MEMORY_PER_JOB_MB 800)
    endif()
    if(NOT CALC_MEMORY_USAGE_PERCENT)
        set(CALC_MEMORY_USAGE_PERCENT 75)
    endif()
    if(NOT CALC_MIN_LEVEL)
        set(CALC_MIN_LEVEL 1)
    endif()
    if(NOT CALC_MAX_LEVEL)
        set(CALC_MAX_LEVEL 32)
    endif()

    if(UNIX AND NOT APPLE)
        execute_process(
            COMMAND bash -c "free -m | awk 'NR==2{printf \"%.0f\", $2/1024}'"
            OUTPUT_VARIABLE SYSTEM_MEMORY_GB
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
    elseif(APPLE)
        execute_process(
            COMMAND bash -c "sysctl -n hw.memsize | awk '{printf \"%.0f\", $1/1024/1024/1024}'"
            OUTPUT_VARIABLE SYSTEM_MEMORY_GB
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
    else()
        set(SYSTEM_MEMORY_GB 8)
    endif()

    if(NOT SYSTEM_MEMORY_GB OR SYSTEM_MEMORY_GB EQUAL 0)
        set(SYSTEM_MEMORY_GB 8)
        message(WARNING "Failed to detect system memory, using default: ${SYSTEM_MEMORY_GB}GB")
    endif()

    math(EXPR MEMORY_BASED_LEVEL "${SYSTEM_MEMORY_GB} * 1024 * ${CALC_MEMORY_USAGE_PERCENT} / 100 / ${CALC_MEMORY_PER_JOB_MB}")
    
    if(DEFINED CMAKE_BUILD_PARALLEL_LEVEL AND CMAKE_BUILD_PARALLEL_LEVEL GREATER 0)
        if(CMAKE_BUILD_PARALLEL_LEVEL LESS ${MEMORY_BASED_LEVEL})
            set(PARALLEL_LEVEL ${CMAKE_BUILD_PARALLEL_LEVEL})
        else()
            set(PARALLEL_LEVEL ${MEMORY_BASED_LEVEL})
        endif()
    else()
        set(PARALLEL_LEVEL ${MEMORY_BASED_LEVEL})
    endif()
    
    if(PARALLEL_LEVEL LESS ${CALC_MIN_LEVEL})
        set(PARALLEL_LEVEL ${CALC_MIN_LEVEL})
    elseif(PARALLEL_LEVEL GREATER ${CALC_MAX_LEVEL})
        set(PARALLEL_LEVEL ${CALC_MAX_LEVEL})
    endif()

    math(EXPR AVAILABLE_MEMORY_MB "${SYSTEM_MEMORY_GB} * 1024 * ${CALC_MEMORY_USAGE_PERCENT} / 100")
    message(STATUS "Detected system memory: ${SYSTEM_MEMORY_GB}GB (${AVAILABLE_MEMORY_MB}MB available for compilation)")
    message(STATUS "Memory-based parallel limit: ${MEMORY_BASED_LEVEL} (${CALC_MEMORY_PER_JOB_MB}MB per job)")
    if(DEFINED CMAKE_BUILD_PARALLEL_LEVEL AND CMAKE_BUILD_PARALLEL_LEVEL GREATER 0)
        message(STATUS "User-specified CMAKE_BUILD_PARALLEL_LEVEL: ${CMAKE_BUILD_PARALLEL_LEVEL}")
    endif()
    message(STATUS "Calculated parallel level: ${PARALLEL_LEVEL}")

    set(${OUTPUT_VAR} ${PARALLEL_LEVEL} PARENT_SCOPE)
endfunction()

function(cal_grpc_parallel_level OUTPUT_VAR)
    cal_parallel_level(${OUTPUT_VAR} 
        MEMORY_PER_JOB_MB 800 
        MEMORY_USAGE_PERCENT 75 
        MIN_LEVEL 1 
        MAX_LEVEL 32
    )
endfunction()
