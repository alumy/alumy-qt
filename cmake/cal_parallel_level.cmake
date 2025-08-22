include(${CMAKE_CURRENT_LIST_DIR}/system_info.cmake)

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

    get_system_memory_gb(SYSTEM_MEMORY_GB)

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
    get_system_memory_free_gb(SYSTEM_MEMORY_FREE_GB)

    if(SYSTEM_MEMORY_FREE_GB LESS 8)
        set(GRPC_MEMORY_PER_JOB 600)
        set(GRPC_USAGE_PERCENT 40)
        set(GRPC_MAX_LEVEL 2)
        message(STATUS "Low memory system (${SYSTEM_MEMORY_FREE_GB}GB): Using conservative gRPC build settings")
    elseif(SYSTEM_MEMORY_FREE_GB LESS 16)
        set(GRPC_MEMORY_PER_JOB 1000)
        set(GRPC_USAGE_PERCENT 60)
        set(GRPC_MAX_LEVEL 4)
        message(STATUS "Medium memory system (${SYSTEM_MEMORY_FREE_GB}GB): Using balanced gRPC build settings")
    elseif(SYSTEM_MEMORY_FREE_GB LESS 32)
        set(GRPC_MEMORY_PER_JOB 1300)
        set(GRPC_USAGE_PERCENT 70)
        set(GRPC_MAX_LEVEL 8)
        message(STATUS "High memory system (${SYSTEM_MEMORY_FREE_GB}GB): Using standard gRPC build settings")
    else()
        set(GRPC_MEMORY_PER_JOB 1500)
        set(GRPC_USAGE_PERCENT 75)
        set(GRPC_MAX_LEVEL 16)
        message(STATUS "Very high memory system (${SYSTEM_MEMORY_FREE_GB}GB): Using high-performance gRPC build settings")
    endif()

    cal_parallel_level(${OUTPUT_VAR} 
        MEMORY_PER_JOB_MB ${GRPC_MEMORY_PER_JOB}
        MEMORY_USAGE_PERCENT ${GRPC_USAGE_PERCENT}
        MIN_LEVEL 1 
        MAX_LEVEL ${GRPC_MAX_LEVEL}
    )
endfunction()
