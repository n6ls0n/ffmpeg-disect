#!/bin/bash

# Update system
pacman -Syu --noconfirm

# Create MinGW64 package list
pacman -Qqe | grep mingw-w64-x86_64 > ./mingw64_packages.txt

echo "MinGW64 package list created: mingw64_packages.txt"

# Optional: Display the list
echo "Installed MinGW64 packages:"
cat ./mingw64_packages.txt
