set(target 3rd-party)

include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/dependencies.cmake)

set(QTSINGLEAPP_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/qt-solutions/qtsingleapplication/src)
set(QWT_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/qwt/src)

# QWT Core source files (always included)
set(QWT_CORE_SOURCES
    ${QWT_SRC_DIR}/qwt.cpp
    ${QWT_SRC_DIR}/qwt_abstract_scale_draw.cpp
    ${QWT_SRC_DIR}/qwt_bezier.cpp
    ${QWT_SRC_DIR}/qwt_clipper.cpp
    ${QWT_SRC_DIR}/qwt_color_map.cpp
    ${QWT_SRC_DIR}/qwt_column_symbol.cpp
    ${QWT_SRC_DIR}/qwt_date.cpp
    ${QWT_SRC_DIR}/qwt_date_scale_draw.cpp
    ${QWT_SRC_DIR}/qwt_date_scale_engine.cpp
    ${QWT_SRC_DIR}/qwt_dyngrid_layout.cpp
    ${QWT_SRC_DIR}/qwt_event_pattern.cpp
    ${QWT_SRC_DIR}/qwt_graphic.cpp
    ${QWT_SRC_DIR}/qwt_interval.cpp
    ${QWT_SRC_DIR}/qwt_interval_symbol.cpp
    ${QWT_SRC_DIR}/qwt_math.cpp
    ${QWT_SRC_DIR}/qwt_magnifier.cpp
    ${QWT_SRC_DIR}/qwt_null_paintdevice.cpp
    ${QWT_SRC_DIR}/qwt_painter.cpp
    ${QWT_SRC_DIR}/qwt_painter_command.cpp
    ${QWT_SRC_DIR}/qwt_panner.cpp
    ${QWT_SRC_DIR}/qwt_picker.cpp
    ${QWT_SRC_DIR}/qwt_picker_machine.cpp
    ${QWT_SRC_DIR}/qwt_pixel_matrix.cpp
    ${QWT_SRC_DIR}/qwt_point_3d.cpp
    ${QWT_SRC_DIR}/qwt_point_polar.cpp
    ${QWT_SRC_DIR}/qwt_round_scale_draw.cpp
    ${QWT_SRC_DIR}/qwt_scale_div.cpp
    ${QWT_SRC_DIR}/qwt_scale_draw.cpp
    ${QWT_SRC_DIR}/qwt_scale_map.cpp
    ${QWT_SRC_DIR}/qwt_scale_engine.cpp
    ${QWT_SRC_DIR}/qwt_spline.cpp
    ${QWT_SRC_DIR}/qwt_spline_basis.cpp
    ${QWT_SRC_DIR}/qwt_spline_parametrization.cpp
    ${QWT_SRC_DIR}/qwt_spline_local.cpp
    ${QWT_SRC_DIR}/qwt_spline_cubic.cpp
    ${QWT_SRC_DIR}/qwt_spline_pleasing.cpp
    ${QWT_SRC_DIR}/qwt_spline_polynomial.cpp
    ${QWT_SRC_DIR}/qwt_symbol.cpp
    ${QWT_SRC_DIR}/qwt_system_clock.cpp
    ${QWT_SRC_DIR}/qwt_text_engine.cpp
    ${QWT_SRC_DIR}/qwt_text_label.cpp
    ${QWT_SRC_DIR}/qwt_text.cpp
    ${QWT_SRC_DIR}/qwt_transform.cpp
    ${QWT_SRC_DIR}/qwt_widget_overlay.cpp
)

# QWT Plot source files
set(QWT_PLOT_SOURCES
    ${QWT_SRC_DIR}/qwt_curve_fitter.cpp
    ${QWT_SRC_DIR}/qwt_spline_curve_fitter.cpp
    ${QWT_SRC_DIR}/qwt_weeding_curve_fitter.cpp
    ${QWT_SRC_DIR}/qwt_abstract_legend.cpp
    ${QWT_SRC_DIR}/qwt_legend.cpp
    ${QWT_SRC_DIR}/qwt_legend_data.cpp
    ${QWT_SRC_DIR}/qwt_legend_label.cpp
    ${QWT_SRC_DIR}/qwt_plot.cpp
    ${QWT_SRC_DIR}/qwt_plot_renderer.cpp
    ${QWT_SRC_DIR}/qwt_plot_axis.cpp
    ${QWT_SRC_DIR}/qwt_plot_curve.cpp
    ${QWT_SRC_DIR}/qwt_plot_dict.cpp
    ${QWT_SRC_DIR}/qwt_plot_directpainter.cpp
    ${QWT_SRC_DIR}/qwt_plot_graphicitem.cpp
    ${QWT_SRC_DIR}/qwt_plot_grid.cpp
    ${QWT_SRC_DIR}/qwt_plot_histogram.cpp
    ${QWT_SRC_DIR}/qwt_plot_item.cpp
    ${QWT_SRC_DIR}/qwt_plot_abstract_barchart.cpp
    ${QWT_SRC_DIR}/qwt_plot_barchart.cpp
    ${QWT_SRC_DIR}/qwt_plot_multi_barchart.cpp
    ${QWT_SRC_DIR}/qwt_plot_intervalcurve.cpp
    ${QWT_SRC_DIR}/qwt_plot_zoneitem.cpp
    ${QWT_SRC_DIR}/qwt_plot_tradingcurve.cpp
    ${QWT_SRC_DIR}/qwt_plot_spectrogram.cpp
    ${QWT_SRC_DIR}/qwt_plot_spectrocurve.cpp
    ${QWT_SRC_DIR}/qwt_plot_scaleitem.cpp
    ${QWT_SRC_DIR}/qwt_plot_legenditem.cpp
    ${QWT_SRC_DIR}/qwt_plot_seriesitem.cpp
    ${QWT_SRC_DIR}/qwt_plot_shapeitem.cpp
    ${QWT_SRC_DIR}/qwt_plot_vectorfield.cpp
    ${QWT_SRC_DIR}/qwt_plot_marker.cpp
    ${QWT_SRC_DIR}/qwt_plot_textlabel.cpp
    ${QWT_SRC_DIR}/qwt_plot_layout.cpp
    ${QWT_SRC_DIR}/qwt_plot_abstract_canvas.cpp
    ${QWT_SRC_DIR}/qwt_plot_canvas.cpp
    ${QWT_SRC_DIR}/qwt_plot_panner.cpp
    ${QWT_SRC_DIR}/qwt_plot_rasteritem.cpp
    ${QWT_SRC_DIR}/qwt_plot_picker.cpp
    ${QWT_SRC_DIR}/qwt_plot_zoomer.cpp
    ${QWT_SRC_DIR}/qwt_plot_magnifier.cpp
    ${QWT_SRC_DIR}/qwt_plot_rescaler.cpp
    ${QWT_SRC_DIR}/qwt_point_mapper.cpp
    ${QWT_SRC_DIR}/qwt_raster_data.cpp
    ${QWT_SRC_DIR}/qwt_matrix_raster_data.cpp
    ${QWT_SRC_DIR}/qwt_vectorfield_symbol.cpp
    ${QWT_SRC_DIR}/qwt_sampling_thread.cpp
    ${QWT_SRC_DIR}/qwt_series_data.cpp
    ${QWT_SRC_DIR}/qwt_point_data.cpp
    ${QWT_SRC_DIR}/qwt_scale_widget.cpp
)

# QWT Polar source files
set(QWT_POLAR_SOURCES
    ${QWT_SRC_DIR}/qwt_polar_canvas.cpp
    ${QWT_SRC_DIR}/qwt_polar_curve.cpp
    ${QWT_SRC_DIR}/qwt_polar_fitter.cpp
    ${QWT_SRC_DIR}/qwt_polar_grid.cpp
    ${QWT_SRC_DIR}/qwt_polar_item.cpp
    ${QWT_SRC_DIR}/qwt_polar_itemdict.cpp
    ${QWT_SRC_DIR}/qwt_polar_layout.cpp
    ${QWT_SRC_DIR}/qwt_polar_magnifier.cpp
    ${QWT_SRC_DIR}/qwt_polar_marker.cpp
    ${QWT_SRC_DIR}/qwt_polar_panner.cpp
    ${QWT_SRC_DIR}/qwt_polar_picker.cpp
    ${QWT_SRC_DIR}/qwt_polar_plot.cpp
    ${QWT_SRC_DIR}/qwt_polar_renderer.cpp
    ${QWT_SRC_DIR}/qwt_polar_spectrogram.cpp
)

# QWT Widgets source files
set(QWT_WIDGETS_SOURCES
    ${QWT_SRC_DIR}/qwt_abstract_slider.cpp
    ${QWT_SRC_DIR}/qwt_abstract_scale.cpp
    ${QWT_SRC_DIR}/qwt_arrow_button.cpp
    ${QWT_SRC_DIR}/qwt_analog_clock.cpp
    ${QWT_SRC_DIR}/qwt_compass.cpp
    ${QWT_SRC_DIR}/qwt_compass_rose.cpp
    ${QWT_SRC_DIR}/qwt_counter.cpp
    ${QWT_SRC_DIR}/qwt_dial.cpp
    ${QWT_SRC_DIR}/qwt_dial_needle.cpp
    ${QWT_SRC_DIR}/qwt_knob.cpp
    ${QWT_SRC_DIR}/qwt_slider.cpp
    ${QWT_SRC_DIR}/qwt_thermo.cpp
    ${QWT_SRC_DIR}/qwt_wheel.cpp
)

# QWT SVG source files (conditional)
set(QWT_SVG_SOURCES
    ${QWT_SRC_DIR}/qwt_plot_svgitem.cpp
)

# QWT OpenGL source files (conditional, Qt version dependent)
set(QWT_OPENGL_SOURCES)
if(QT_VERSION_MAJOR EQUAL 5)
    list(APPEND QWT_OPENGL_SOURCES
        ${QWT_SRC_DIR}/qwt_plot_glcanvas.cpp
        ${QWT_SRC_DIR}/qwt_plot_opengl_canvas.cpp
    )
elseif(QT_VERSION_MAJOR EQUAL 6)
    list(APPEND QWT_OPENGL_SOURCES
        ${QWT_SRC_DIR}/qwt_plot_opengl_canvas.cpp
    )
endif()

# Combine all QWT sources
set(QWT_ALL_SOURCES
    ${QWT_CORE_SOURCES}
    ${QWT_PLOT_SOURCES}
    ${QWT_POLAR_SOURCES}
    ${QWT_WIDGETS_SOURCES}
    ${QWT_SVG_SOURCES}
    ${QWT_OPENGL_SOURCES}
)

# QWT Core header files (always included)
set(QWT_CORE_HEADERS
    ${QWT_SRC_DIR}/qwt.h
    ${QWT_SRC_DIR}/qwt_abstract_scale_draw.h
    ${QWT_SRC_DIR}/qwt_bezier.h
    ${QWT_SRC_DIR}/qwt_clipper.h
    ${QWT_SRC_DIR}/qwt_color_map.h
    ${QWT_SRC_DIR}/qwt_column_symbol.h
    ${QWT_SRC_DIR}/qwt_date.h
    ${QWT_SRC_DIR}/qwt_date_scale_draw.h
    ${QWT_SRC_DIR}/qwt_date_scale_engine.h
    ${QWT_SRC_DIR}/qwt_dyngrid_layout.h
    ${QWT_SRC_DIR}/qwt_global.h
    ${QWT_SRC_DIR}/qwt_graphic.h
    ${QWT_SRC_DIR}/qwt_interval.h
    ${QWT_SRC_DIR}/qwt_interval_symbol.h
    ${QWT_SRC_DIR}/qwt_math.h
    ${QWT_SRC_DIR}/qwt_magnifier.h
    ${QWT_SRC_DIR}/qwt_null_paintdevice.h
    ${QWT_SRC_DIR}/qwt_painter.h
    ${QWT_SRC_DIR}/qwt_painter_command.h
    ${QWT_SRC_DIR}/qwt_panner.h
    ${QWT_SRC_DIR}/qwt_picker.h
    ${QWT_SRC_DIR}/qwt_picker_machine.h
    ${QWT_SRC_DIR}/qwt_pixel_matrix.h
    ${QWT_SRC_DIR}/qwt_point_3d.h
    ${QWT_SRC_DIR}/qwt_point_polar.h
    ${QWT_SRC_DIR}/qwt_round_scale_draw.h
    ${QWT_SRC_DIR}/qwt_scale_div.h
    ${QWT_SRC_DIR}/qwt_scale_draw.h
    ${QWT_SRC_DIR}/qwt_scale_engine.h
    ${QWT_SRC_DIR}/qwt_scale_map.h
    ${QWT_SRC_DIR}/qwt_spline.h
    ${QWT_SRC_DIR}/qwt_spline_basis.h
    ${QWT_SRC_DIR}/qwt_spline_parametrization.h
    ${QWT_SRC_DIR}/qwt_spline_local.h
    ${QWT_SRC_DIR}/qwt_spline_cubic.h
    ${QWT_SRC_DIR}/qwt_spline_pleasing.h
    ${QWT_SRC_DIR}/qwt_spline_polynomial.h
    ${QWT_SRC_DIR}/qwt_symbol.h
    ${QWT_SRC_DIR}/qwt_system_clock.h
    ${QWT_SRC_DIR}/qwt_text_engine.h
    ${QWT_SRC_DIR}/qwt_text_label.h
    ${QWT_SRC_DIR}/qwt_text.h
    ${QWT_SRC_DIR}/qwt_transform.h
    ${QWT_SRC_DIR}/qwt_widget_overlay.h
)

# QWT Plot header files
set(QWT_PLOT_HEADERS
    ${QWT_SRC_DIR}/qwt_axis.h
    ${QWT_SRC_DIR}/qwt_axis_id.h
    ${QWT_SRC_DIR}/qwt_curve_fitter.h
    ${QWT_SRC_DIR}/qwt_spline_curve_fitter.h
    ${QWT_SRC_DIR}/qwt_weeding_curve_fitter.h
    ${QWT_SRC_DIR}/qwt_event_pattern.h
    ${QWT_SRC_DIR}/qwt_abstract_legend.h
    ${QWT_SRC_DIR}/qwt_legend.h
    ${QWT_SRC_DIR}/qwt_legend_data.h
    ${QWT_SRC_DIR}/qwt_legend_label.h
    ${QWT_SRC_DIR}/qwt_plot.h
    ${QWT_SRC_DIR}/qwt_plot_renderer.h
    ${QWT_SRC_DIR}/qwt_plot_curve.h
    ${QWT_SRC_DIR}/qwt_plot_dict.h
    ${QWT_SRC_DIR}/qwt_plot_directpainter.h
    ${QWT_SRC_DIR}/qwt_plot_graphicitem.h
    ${QWT_SRC_DIR}/qwt_plot_grid.h
    ${QWT_SRC_DIR}/qwt_plot_histogram.h
    ${QWT_SRC_DIR}/qwt_plot_item.h
    ${QWT_SRC_DIR}/qwt_plot_abstract_barchart.h
    ${QWT_SRC_DIR}/qwt_plot_barchart.h
    ${QWT_SRC_DIR}/qwt_plot_multi_barchart.h
    ${QWT_SRC_DIR}/qwt_plot_intervalcurve.h
    ${QWT_SRC_DIR}/qwt_plot_tradingcurve.h
    ${QWT_SRC_DIR}/qwt_plot_layout.h
    ${QWT_SRC_DIR}/qwt_plot_marker.h
    ${QWT_SRC_DIR}/qwt_plot_zoneitem.h
    ${QWT_SRC_DIR}/qwt_plot_textlabel.h
    ${QWT_SRC_DIR}/qwt_plot_rasteritem.h
    ${QWT_SRC_DIR}/qwt_plot_spectrogram.h
    ${QWT_SRC_DIR}/qwt_plot_spectrocurve.h
    ${QWT_SRC_DIR}/qwt_plot_scaleitem.h
    ${QWT_SRC_DIR}/qwt_plot_legenditem.h
    ${QWT_SRC_DIR}/qwt_plot_seriesitem.h
    ${QWT_SRC_DIR}/qwt_plot_shapeitem.h
    ${QWT_SRC_DIR}/qwt_plot_vectorfield.h
    ${QWT_SRC_DIR}/qwt_plot_abstract_canvas.h
    ${QWT_SRC_DIR}/qwt_plot_canvas.h
    ${QWT_SRC_DIR}/qwt_plot_panner.h
    ${QWT_SRC_DIR}/qwt_plot_picker.h
    ${QWT_SRC_DIR}/qwt_plot_zoomer.h
    ${QWT_SRC_DIR}/qwt_plot_magnifier.h
    ${QWT_SRC_DIR}/qwt_plot_rescaler.h
    ${QWT_SRC_DIR}/qwt_point_mapper.h
    ${QWT_SRC_DIR}/qwt_raster_data.h
    ${QWT_SRC_DIR}/qwt_matrix_raster_data.h
    ${QWT_SRC_DIR}/qwt_vectorfield_symbol.h
    ${QWT_SRC_DIR}/qwt_sampling_thread.h
    ${QWT_SRC_DIR}/qwt_samples.h
    ${QWT_SRC_DIR}/qwt_series_data.h
    ${QWT_SRC_DIR}/qwt_series_store.h
    ${QWT_SRC_DIR}/qwt_point_data.h
    ${QWT_SRC_DIR}/qwt_scale_widget.h
)

# QWT Polar header files
set(QWT_POLAR_HEADERS
    ${QWT_SRC_DIR}/qwt_polar.h
    ${QWT_SRC_DIR}/qwt_polar_canvas.h
    ${QWT_SRC_DIR}/qwt_polar_curve.h
    ${QWT_SRC_DIR}/qwt_polar_fitter.h
    ${QWT_SRC_DIR}/qwt_polar_grid.h
    ${QWT_SRC_DIR}/qwt_polar_itemdict.h
    ${QWT_SRC_DIR}/qwt_polar_item.h
    ${QWT_SRC_DIR}/qwt_polar_layout.h
    ${QWT_SRC_DIR}/qwt_polar_magnifier.h
    ${QWT_SRC_DIR}/qwt_polar_marker.h
    ${QWT_SRC_DIR}/qwt_polar_panner.h
    ${QWT_SRC_DIR}/qwt_polar_picker.h
    ${QWT_SRC_DIR}/qwt_polar_plot.h
    ${QWT_SRC_DIR}/qwt_polar_renderer.h
    ${QWT_SRC_DIR}/qwt_polar_spectrogram.h
)

# QWT Widgets header files
set(QWT_WIDGETS_HEADERS
    ${QWT_SRC_DIR}/qwt_abstract_slider.h
    ${QWT_SRC_DIR}/qwt_abstract_scale.h
    ${QWT_SRC_DIR}/qwt_arrow_button.h
    ${QWT_SRC_DIR}/qwt_analog_clock.h
    ${QWT_SRC_DIR}/qwt_compass.h
    ${QWT_SRC_DIR}/qwt_compass_rose.h
    ${QWT_SRC_DIR}/qwt_counter.h
    ${QWT_SRC_DIR}/qwt_dial.h
    ${QWT_SRC_DIR}/qwt_dial_needle.h
    ${QWT_SRC_DIR}/qwt_knob.h
    ${QWT_SRC_DIR}/qwt_slider.h
    ${QWT_SRC_DIR}/qwt_thermo.h
    ${QWT_SRC_DIR}/qwt_wheel.h
)

# QWT SVG header files
set(QWT_SVG_HEADERS
    ${QWT_SRC_DIR}/qwt_plot_svgitem.h
)

# QWT OpenGL header files (conditional)
set(QWT_OPENGL_HEADERS)
if(QT_VERSION_MAJOR EQUAL 5)
    list(APPEND QWT_OPENGL_HEADERS
        ${QWT_SRC_DIR}/qwt_plot_glcanvas.h
        ${QWT_SRC_DIR}/qwt_plot_opengl_canvas.h
    )
elseif(QT_VERSION_MAJOR EQUAL 6)
    list(APPEND QWT_OPENGL_HEADERS
        ${QWT_SRC_DIR}/qwt_plot_opengl_canvas.h
    )
endif()

# Combine all QWT headers
set(QWT_ALL_HEADERS
    ${QWT_CORE_HEADERS}
    ${QWT_PLOT_HEADERS}
    ${QWT_POLAR_HEADERS}
    ${QWT_WIDGETS_HEADERS}
    ${QWT_SVG_HEADERS}
    ${QWT_OPENGL_HEADERS}
)

set(${target}_src 
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.cpp
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.h
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.cpp
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.h
    ${QWT_ALL_SOURCES}
    ${QWT_ALL_HEADERS}
)

add_library(${target} OBJECT ${${target}_src})

target_include_directories(${target} PUBLIC 
    $<BUILD_INTERFACE:${QTSINGLEAPP_SRC_DIR}>
    $<BUILD_INTERFACE:${QWT_SRC_DIR}>
    $<INSTALL_INTERFACE:include>
)

target_link_libraries(${target} PUBLIC
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Network
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Widgets
)

# Add Qt5/6 specific dependencies for QWT
if(QT_VERSION_MAJOR GREATER 4)
    target_link_libraries(${target} PUBLIC
        Qt${QT_VERSION_MAJOR}::PrintSupport
        Qt${QT_VERSION_MAJOR}::Concurrent
    )
endif()

# Add SVG support if available
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Svg QUIET)
if(Qt${QT_VERSION_MAJOR}Svg_FOUND)
    target_link_libraries(${target} PUBLIC Qt${QT_VERSION_MAJOR}::Svg)
    target_compile_definitions(${target} PUBLIC QWT_SVG)
else()
    target_compile_definitions(${target} PUBLIC QWT_NO_SVG)
endif()

# Add OpenGL support if available
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS OpenGL QUIET)
if(Qt${QT_VERSION_MAJOR}OpenGL_FOUND)
    target_link_libraries(${target} PUBLIC Qt${QT_VERSION_MAJOR}::OpenGL)
    target_compile_definitions(${target} PUBLIC QWT_OPENGL)
    
    # For Qt6, also try to find OpenGLWidgets
    if(QT_VERSION_MAJOR EQUAL 6)
        find_package(Qt${QT_VERSION_MAJOR} COMPONENTS OpenGLWidgets QUIET)
        if(Qt${QT_VERSION_MAJOR}OpenGLWidgets_FOUND)
            target_link_libraries(${target} PUBLIC Qt${QT_VERSION_MAJOR}::OpenGLWidgets)
        endif()
    endif()
else()
    target_compile_definitions(${target} PUBLIC QWT_NO_OPENGL)
endif()

# QWT specific compile definitions
target_compile_definitions(${target} PUBLIC
    QWT_MOC_INCLUDE=1
    QWT_DLL
)

configure_alumy_dependencies()

add_alumy_dependencies(${target})

link_alumy_dependencies(${target})

install_alumy_dependencies()

target_include_directories(${target} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
    $<INSTALL_INTERFACE:include>
)

install(FILES 
    ${QTSINGLEAPP_SRC_DIR}/qtsingleapplication.h
    ${QTSINGLEAPP_SRC_DIR}/qtlocalpeer.h
    ${QWT_ALL_HEADERS}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

install(TARGETS ${target}
    EXPORT alumy-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
