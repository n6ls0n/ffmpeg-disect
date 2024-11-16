#!/bin/bash

# Update system
echo "Updating system..."
pacman -Syu --noconfirm

# Get the install date of the base package (as a reference for system install date)
echo "Getting base install date..."
base_install_date=$(pacman -Qi base | grep "Install Date" | cut -d: -f2- | xargs -I{} date -d "{}" +%s)

# Get total number of mingw-w64 packages
total_packages=$(pacman -Qq | grep "mingw-w64-x86_64" | wc -l)
echo "Total MinGW64 packages: $total_packages"

# Counter for processed packages
counter=0

# Clear the output file
> ./mingw-w64-packages.txt

# Get list of mingw-w64 packages installed after the base package
echo "Processing packages..."
pacman -Qq | grep "mingw-w64-x86_64" | while read pkg; do
    # Update and display progress
    counter=$((counter + 1))
    progress=$((counter * 100 / total_packages))
    printf "\rProgress: [%-50s] %d%%" $(printf "#%.0s" $(seq 1 $((progress / 2)))) $progress

    pkg_date=$(pacman -Qi "$pkg" | grep "Install Date" | cut -d: -f2- | xargs -I{} date -d "{}" +%s)
    if [ $pkg_date -gt $base_install_date ]; then
        echo "$pkg" >> ./mingw-w64-packages.txt
    fi
done

echo -e "\nMinGW64 package list created: mingw-w64-packages.txt"

# Optional: Display the list
echo "Installed non-default MinGW64 packages:"
cat ./mingw-w64-packages.txt
