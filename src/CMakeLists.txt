make_executable()

include_directories(
    ${GLM_INCLUDE_DIR}
    )
    
target_link_libraries(${PROJECT}
    ${GLFW_LIBRARIES}
    ${GLM_LIBRARIES}
    ${VULKAN_LIBRARIES}
    )
