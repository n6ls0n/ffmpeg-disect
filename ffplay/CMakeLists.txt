cmake_minimum_required(VERSION 3.10)
project(ffplay CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set GUI_TYPE for Windows
if(WIN32)
    set(GUI_TYPE WIN32)
endif()

# Set MSYS2 MinGW-w64 environment
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

# Set MinGW-w64 bin directory
set(MINGW_BIN_DIR "C:/msys64/mingw64/bin")

# Find required packages
find_package(SDL2 REQUIRED)

# Set FFMPEG libraries
set(FFMPEG_LIBRARIES
    ${FFMPEG_LIB_DIR}/libavcodec.dll.a
    ${FFMPEG_LIB_DIR}/libavformat.dll.a
    ${FFMPEG_LIB_DIR}/libavutil.dll.a
    ${FFMPEG_LIB_DIR}/libavdevice.dll.a
    ${FFMPEG_LIB_DIR}/libavfilter.dll.a
    ${FFMPEG_LIB_DIR}/libpostproc.dll.a
    ${FFMPEG_LIB_DIR}/libswresample.dll.a
    ${FFMPEG_LIB_DIR}/libswscale.dll.a
)

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

# Define the executable with C++ sources
add_executable(${PROJECT_NAME} ${GUI_TYPE}
    ffplay.cpp
    ${IMGUI_SOURCES}
    ${FFTOOLS_LIB_DIR}
)

# Set include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${INCLUDES_DIR}
    ${SDL2_INCLUDE_DIRS}
    ${FFMPEG_INCLUDE_DIR}
    ${IMGUI_INCLUDE_DIR}
    ${FFTOOLS_INCLUDE_DIR}
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
