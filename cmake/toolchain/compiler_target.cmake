function(compiler_target COMPILER TARGET)
    execute_process(
        COMMAND ${COMPILER} -dumpmachine
        RESULT_VARIABLE _result
        OUTPUT_VARIABLE _target
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(_result EQUAL 0)
        set(${TARGET} "${_target}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Failed to run ${COMPILER} -dumpmachine")
    endif()
endfunction()
