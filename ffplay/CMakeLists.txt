cmake_minimum_required(VERSION 3.10)
project(ffplay C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_AS_GUI "Build as GUI application" ON)

if(WIN32 AND BUILD_AS_GUI)
    set(GUI_TYPE WIN32)
else()
    set(GUI_TYPE "")
endif()

if(BUILD_AS_GUI)
    add_definitions(-DBUILD_AS_GUI)
endif()

add_definitions(-DSDL_MAIN_HANDLED)

set(CMAKE_C_COMPILER "gcc")
set(CMAKE_CXX_COMPILER "g++")

# Set paths to look for libraries and includes
set(LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs")
set(INCLUDES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")

# Set FFMPEG directories
set(FFMPEG_INCLUDE_DIR "${INCLUDES_DIR}/ffmpeg-include")
set(FFMPEG_LIB_DIR "${LIB_DIR}/ffmpeg-libs/lib")
set(FFMPEG_BIN_DIR "${LIB_DIR}/ffmpeg-libs/bin")

# Set FFTOOLS directories
set(FFTOOLS_INCLUDE_DIR "${INCLUDES_DIR}/fftools-incl")
set(FFTOOLS_LIB_DIR "${LIB_DIR}/fftools-libs")

# Check if FFtools directory exists
if(NOT EXISTS ${FFTOOLS_LIB_DIR})
    message(FATAL_ERROR "FFtools directory not found: ${FFTOOLS_LIB_DIR}")
endif()

# Set MinGW-w64 bin directory
set(MINGW_BIN_DIR "C:/msys64/mingw64/bin")

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

# Find SDL2 package
find_package(SDL2 REQUIRED)

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

file(GLOB FFMPEG_DLLS "${FFMPEG_BIN_DIR}/*.dll")
file(GLOB MINGW_DLLS "${MINGW_BIN_DIR}/libgcc_s_seh-1.dll" "${MINGW_BIN_DIR}/libstdc++-6.dll" "${MINGW_BIN_DIR}/libwinpthread-1.dll")

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Copying FFMPEG and MinGW DLLs..."
    COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${FFMPEG_DLLS} "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MINGW_DLLS} "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
    COMMAND ${CMAKE_COMMAND} -E echo "FFMPEG and MinGW DLLs copied successfully"
)

if(WIN32)
    if(BUILD_AS_GUI)
        set_target_properties(${PROJECT_NAME} PROPERTIES
            WIN32_EXECUTABLE TRUE
            LINK_FLAGS "-mwindows"
        )
    else()
        set_target_properties(${PROJECT_NAME} PROPERTIES
            WIN32_EXECUTABLE FALSE
            LINK_FLAGS "-mconsole"
        )
    endif()
endif()
