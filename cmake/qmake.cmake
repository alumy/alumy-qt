
get_target_property(QMAKE Qt${QT_VERSION_MAJOR}::qmake IMPORTED_LOCATION)

if(NOT QMAKE)
    message(FATAL_ERROR "Could not find qmake executable")
endif()

message(STATUS "Found qmake: ${QMAKE}")