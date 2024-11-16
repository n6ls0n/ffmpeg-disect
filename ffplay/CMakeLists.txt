cmake_minimum_required(VERSION 3.10)
project(ffplay C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set MSYS2 MinGW-w64 environment
set(CMAKE_C_COMPILER "gcc")
set(CMAKE_CXX_COMPILER "g++")

# Set paths to look for libraries and includes at the same folder level
set(LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs")
set(INCLUDES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")

# Find required packages
find_package(SDL2 REQUIRED)
find_package(FFMPEG REQUIRED COMPONENTS
    avcodec avformat avutil avdevice avfilter
    postproc swresample swscale
)

# Add ImGui source files
set(IMGUI_DIR "${CMAKE_CURRENT_SOURCE_DIR}/imgui")
set(IMGUI_SOURCES
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_demo.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/backends/imgui_impl_sdl2.cpp
    ${IMGUI_DIR}/backends/imgui_impl_sdlrenderer.cpp
)

# Define the executable with both C and C++ sources
add_executable(${PROJECT_NAME}
    ffplay.c
    ${IMGUI_SOURCES}
)

# Set include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${INCLUDES_DIR}
    ${SDL2_INCLUDE_DIRS}
    ${FFMPEG_INCLUDE_DIRS}
    ${IMGUI_DIR}
    ${IMGUI_DIR}/backends
)

# Link libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    ${SDL2_LIBRARIES}
    ${FFMPEG_LIBRARIES}
)

# Add custom target for copying resources (if needed)
add_custom_target(copy_resources ALL)

# Make sure the resources are copied before building the executable
add_dependencies(${PROJECT_NAME} copy_resources)

# Set C++ compiler flags for ImGui files
set_source_files_properties(${IMGUI_SOURCES} PROPERTIES COMPILE_FLAGS "-x c++")

# Set C compiler flags for the main file
set_source_files_properties(ffplay.c PROPERTIES COMPILE_FLAGS "-x c")
