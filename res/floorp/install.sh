#!/bin/bash

# Define app information (modify based on your app)
pkg_name="floorp"
app_archive="floorp-11.9.0.linux-x86_64.tar.bz2"  # Adjust the filename if needed
desktop_file="./floorp.desktop"
icon_path="./floorp.png"

# Define app image sizes to resize (optional)
icon_sizes=(32 64 128 256 512)

# Ensure script is executed with arguments (optional)
# if [[ $# -ne 1 ]]; then
#   echo "Usage: $0 <app_package_file>"
#   exit 1
# fi

# Extract the app archive (using tar)
tar -xvf "$app_archive" || {
  echo "Error: Unable to extract $app_archive"
  exit 1
}

# Move the desktop file to applications directory
# You might need to sudo here depending on permissions
sudo mv "$desktop_file" "/usr/share/applications/$pkg_name.desktop"

# Resize app image for each size (optional)
if [[ -n "$icon_path" ]]; then
  for size in "${icon_sizes[@]}"; do
    # Run convert commands with sudo due to permissions
    sudo convert -resize "${size}x${size}" "$icon_path" "/usr/share/icons/hicolor/${size}x${size}/apps/$pkg_name.png"
    sudo optipng "/usr/share/icons/hicolor/${size}x${size}/apps/$pkg_name.png"
    sudo chmod 644 "/usr/share/icons/hicolor/${size}x${size}/apps/$pkg_name.png"
  done
fi

# Move extracted folder and create symlink
extracted_folder="floorp"  # Adjust if the extracted folder has a different name
# Verify the extracted folder name and adjust accordingly
if [[ ! -d "$extracted_folder" ]]; then
  echo "Error: Extracted folder '$extracted_folder' not found!"
  exit 1
fi

# Move the extracted folder with sudo due to permissions
sudo mv "$extracted_folder" "/opt/$pkg_name/"

# Ensure the binary name matches (adjust if needed)
binary_name="floorp"  # Make sure this matches the actual binary name within the extracted folder
# Create the symlink with sudo due to permissions
sudo ln -sf "/opt/$pkg_name/$extracted_folder/$binary_name" "/usr/local/bin/$pkg_name"

echo "App $pkg_name successfully installed!"
