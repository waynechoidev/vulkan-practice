if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose build type: Debug  Release" FORCE)
endif ()

macro(make_project_)
    if (NOT DEFINED PROJECT)
        get_filename_component(PROJECT ${CMAKE_CURRENT_SOURCE_DIR} NAME)
    endif ()

    project(${PROJECT} CXX)
    
    file(GLOB HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/*.h)
    file(GLOB SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)

    source_group("Header Files" FILES ${HEADERS})
    source_group("Source Files" FILES ${SOURCES})
endmacro ()

# Function to compile GLSL to SPIR-V
function(compile_shader input_file output_file)
    get_filename_component(output_dir ${output_file} DIRECTORY)
    add_custom_command(
        OUTPUT ${output_file}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${output_dir}
        COMMAND glslangValidator -V ${input_file} -o ${output_file}
        DEPENDS ${input_file}
        COMMENT "Compiling ${input_file} to ${output_file}"
    )
endfunction()

macro(make_executable)
    make_project_()
    add_executable(${PROJECT} ${HEADERS} ${SOURCES})
    
    install(
        TARGETS ${PROJECT}
        DESTINATION "${CMAKE_SOURCE_DIR}/bundle")
        
    add_custom_command(
        TARGET ${PROJECT}
        PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E create_symlink
            ${CMAKE_CURRENT_SOURCE_DIR}/Textures
            ${CMAKE_CURRENT_BINARY_DIR}/Textures)

    # Shader files
    file(GLOB SHADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/Shaders/*.vert
        ${CMAKE_CURRENT_SOURCE_DIR}/Shaders/*.frag
        ${CMAKE_CURRENT_SOURCE_DIR}/Shaders/*.glsl
    )

    # Compiled SPIR-V files
    set(COMPILED_SHADERS "")
    foreach(shader ${SHADERS})
        get_filename_component(shader_name ${shader} NAME)
        set(output_file ${CMAKE_CURRENT_BINARY_DIR}/Shaders/${shader_name}.spv)
        compile_shader(${shader} ${output_file})
        list(APPEND COMPILED_SHADERS ${output_file})
    endforeach()

    # Create a custom target for shaders
    add_custom_target(Shaders ALL DEPENDS ${COMPILED_SHADERS})

    # Ensure shaders are built before the executable
    add_dependencies(${PROJECT} Shaders)

endmacro()