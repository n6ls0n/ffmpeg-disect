#!/bin/bash

# Name of the text file containing package names
PACKAGE_FILE="packages.txt"

# Check if the file exists
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: $PACKAGE_FILE not found!"
    exit 1
fi

# Read the file and install packages
while IFS= read -r package || [[ -n "$package" ]]; do
    # Trim whitespace
    package=$(echo "$package" | xargs)

    # Skip empty lines
    if [ -z "$package" ]; then
        continue
    fi

    echo "Installing $package..."
    pacman -S --noconfirm "$package"

    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo "$package installed successfully."
    else
        echo "Failed to install $package."
    fi
    echo "----------------------------"
done < "$PACKAGE_FILE"

echo "Installation process completed."
