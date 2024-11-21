cmake_minimum_required(VERSION 3.10)
project(ffplay C CXX)  # Add C language

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set GUI_TYPE for Windows
if(WIN32)
    set(GUI_TYPE WIN32)
endif()

# Set MSYS2 MinGW-w64 environment
set(CMAKE_C_COMPILER "gcc")
set(CMAKE_CXX_COMPILER "g++")

# Set paths to look for libraries and includes at the same folder level
set(LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs")
set(INCLUDES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")

# Set FFMPEG directories
set(FFMPEG_INCLUDE_DIR "C:/msys64/mingw64/include")
set(FFMPEG_LIB_DIR "C:/msys64/mingw64/lib")
set(FFMPEG_BIN_DIR "C:/msys64/mingw64/bin")

# Set FFTOOLS directories
set(FFTOOLS_INCLUDE_DIR "${INCLUDES_DIR}/fftools-incl")
set(FFTOOLS_LIB_DIR "${LIB_DIR}/fftools-libs")

# Check if FFtools directory exists
if(NOT EXISTS ${FFTOOLS_LIB_DIR})
    message(FATAL_ERROR "FFtools directory not found: ${FFTOOLS_LIB_DIR}")
endif()

# Set MinGW-w64 bin directory
set(MINGW_BIN_DIR "C:/msys64/mingw64/bin")

# Find required packages
find_package(SDL2 REQUIRED)

# Set FFMPEG libraries
set(FFMPEG_LIBRARIES
    avcodec
    avformat
    avutil
    avdevice
    avfilter
    postproc
    swresample
    swscale
)

# Add platform-specific libraries
if(NOT WIN32)
    list(APPEND FFMPEG_LIBRARIES m pthread)
else()
    list(APPEND FFMPEG_LIBRARIES bcrypt)
endif()

# Add ImGui source files
set(IMGUI_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs/imgui-libs")
set(IMGUI_SOURCES
    ${IMGUI_LIB_DIR}/imgui.cpp
    ${IMGUI_LIB_DIR}/imgui_demo.cpp
    ${IMGUI_LIB_DIR}/imgui_draw.cpp
    ${IMGUI_LIB_DIR}/imgui_tables.cpp
    ${IMGUI_LIB_DIR}/imgui_widgets.cpp
    ${IMGUI_LIB_DIR}/imgui_impl_sdl2.cpp
    ${IMGUI_LIB_DIR}/imgui_impl_sdlrenderer2.cpp
)

set(IMGUI_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include/imgui-incl")

# Add FFtools source files
file(GLOB FFTOOLS_SOURCES "${FFTOOLS_LIB_DIR}/*.c")

# Create a static library for FFtools
add_library(fftools STATIC ${FFTOOLS_SOURCES})
set_target_properties(fftools PROPERTIES LINKER_LANGUAGE C)

# Set include directories for fftools
target_include_directories(fftools PRIVATE
    ${FFMPEG_INCLUDE_DIR}
    ${FFTOOLS_INCLUDE_DIR}
)

# Link FFmpeg libraries to fftools
target_link_libraries(fftools PRIVATE ${FFMPEG_LIBRARIES})

# Define the executable with C++ sources
add_executable(${PROJECT_NAME} ${GUI_TYPE}
    ffplay.cpp
    ${IMGUI_SOURCES}
)

# Set include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${INCLUDES_DIR}
    ${SDL2_INCLUDE_DIRS}
    ${FFMPEG_INCLUDE_DIR}
    ${IMGUI_INCLUDE_DIR}
    ${FFTOOLS_INCLUDE_DIR}
    ${FFTOOLS_LIB_DIR}
)

# Add FFmpeg library directory to link path
link_directories(${FFMPEG_LIB_DIR})

# Link libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    ${SDL2_LIBRARIES}
    ${FFMPEG_LIBRARIES}
    fftools
)

# Add custom target for copying resources (if needed)
add_custom_target(copy_resources ALL)

# Make sure the resources are copied before building the executable
add_dependencies(${PROJECT_NAME} copy_resources)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Copying FFMPEG and MinGW DLLs..."
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${FFMPEG_BIN_DIR}/avcodec-61.dll
        ${FFMPEG_BIN_DIR}/avformat-61.dll
        ${FFMPEG_BIN_DIR}/avutil-59.dll
        ${FFMPEG_BIN_DIR}/avdevice-61.dll
        ${FFMPEG_BIN_DIR}/avfilter-10.dll
        ${FFMPEG_BIN_DIR}/swresample-5.dll
        ${FFMPEG_BIN_DIR}/swscale-8.dll
        ${FFMPEG_BIN_DIR}/postproc-58.dll
        ${MINGW_BIN_DIR}/libgcc_s_seh-1.dll
        ${MINGW_BIN_DIR}/libstdc++-6.dll
        ${MINGW_BIN_DIR}/libwinpthread-1.dll
        $<TARGET_FILE_DIR:${PROJECT_NAME}>
    COMMAND ${CMAKE_COMMAND} -E echo "FFMPEG and MinGW DLLs copied successfully"
)

if(WIN32)
    target_link_options(${PROJECT_NAME} PRIVATE -mwindows)
endif()
