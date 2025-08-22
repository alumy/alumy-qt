function(get_system_memory_gb OUTPUT_VAR)
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
    elseif(WIN32)
        execute_process(
            COMMAND powershell -Command "Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory | ForEach-Object { [math]::Round($_ / 1073741824, 0) }"
            OUTPUT_VARIABLE SYSTEM_MEMORY_GB
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(NOT SYSTEM_MEMORY_GB OR SYSTEM_MEMORY_GB EQUAL 0)
            execute_process(
                COMMAND wmic computersystem get TotalPhysicalMemory /value
                OUTPUT_VARIABLE WMIC_OUTPUT
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
            if(WMIC_OUTPUT)
                string(REGEX MATCH "TotalPhysicalMemory=([0-9]+)" MATCH_RESULT "${WMIC_OUTPUT}")
                if(CMAKE_MATCH_1)
                    math(EXPR SYSTEM_MEMORY_GB "${CMAKE_MATCH_1} / 1073741824")
                endif()
            endif()
        endif()
    else()
        set(SYSTEM_MEMORY_GB 8)
    endif()

    if(NOT SYSTEM_MEMORY_GB OR SYSTEM_MEMORY_GB EQUAL 0)
        set(SYSTEM_MEMORY_GB 8)
        message(WARNING "Failed to detect system memory, using default: ${SYSTEM_MEMORY_GB}GB")
    endif()

    set(${OUTPUT_VAR} ${SYSTEM_MEMORY_GB} PARENT_SCOPE)
endfunction()

function(get_system_memory_free_gb OUTPUT_VAR)
    if(UNIX AND NOT APPLE)
        execute_process(
            COMMAND bash -c "free -m | awk 'NR==2{printf \"%.1f\", $7/1024}'"
            OUTPUT_VARIABLE SYSTEM_MEMORY_FREE_GB
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
    elseif(APPLE)
        execute_process(
            COMMAND bash -c "vm_stat | awk '/Pages free:/{free=$3} /Pages inactive:/{inactive=$3} END{printf \"%.1f\", (free+inactive)*4096/1024/1024/1024}'"
            OUTPUT_VARIABLE SYSTEM_MEMORY_FREE_GB
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
    elseif(WIN32)
        execute_process(
            COMMAND powershell -Command "Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty FreePhysicalMemory | ForEach-Object { [math]::Round($_ / 1048576, 1) }"
            OUTPUT_VARIABLE SYSTEM_MEMORY_FREE_GB
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(NOT SYSTEM_MEMORY_FREE_GB OR SYSTEM_MEMORY_FREE_GB EQUAL 0)
            execute_process(
                COMMAND wmic OS get FreePhysicalMemory /value
                OUTPUT_VARIABLE WMIC_OUTPUT
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
            if(WMIC_OUTPUT)
                string(REGEX MATCH "FreePhysicalMemory=([0-9]+)" MATCH_RESULT "${WMIC_OUTPUT}")
                if(CMAKE_MATCH_1)
                    math(EXPR SYSTEM_MEMORY_FREE_GB "${CMAKE_MATCH_1} / 1048576")
                endif()
            endif()
        endif()
    else()
        set(SYSTEM_MEMORY_FREE_GB 4)
    endif()

    if(NOT SYSTEM_MEMORY_FREE_GB OR SYSTEM_MEMORY_FREE_GB EQUAL 0)
        set(SYSTEM_MEMORY_FREE_GB 4)
        message(WARNING "Failed to detect free system memory, using default: ${SYSTEM_MEMORY_FREE_GB}GB")
    endif()

    set(${OUTPUT_VAR} ${SYSTEM_MEMORY_FREE_GB} PARENT_SCOPE)
endfunction()

