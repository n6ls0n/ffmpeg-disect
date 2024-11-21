#!/bin/bash

# Redirect all output to output.txt
exec > output.txt 2>&1

# Check if build directory exists and remove it if it does
if [ -d "build" ]; then
    echo "Removing existing build directory..."
    rm -rf build
fi

# Create and enter build directory
mkdir build
cd build

# Run CMake
cmake ..

# Build the project
cmake --build .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful. Running ffplay..."
    # Run the executable
    ./ffplay
else
    echo "Build failed. Please check the error messages above."
fi
