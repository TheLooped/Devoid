#!/bin/bash

set -e
set -u
set -o pipefail

# Color codes
color() {
    case "$1" in
        red) color_code="\033[1;91m";; # Errors or Warnings
        yellow) color_code="\033[1;93m";; # Pending actions
        green) color_code="\033[1;92m";; # Successful completion
        blue) color_code="\033[1;94m";; # Section headings
        cyan) color_code="\033[38;2;0;255;255m";; # Informational messages
        magenta) color_code="\033[38;5;207m";; # Program-specific messages (More vibrant magenta)
        purple) color_code="\033[38;5;141m";; # Prompts (Pastel purple)
        orange) color_code="\033[38;5;216m";; # Labels for data elements (More vibrant orange)
        lavender) color_code="\033[38;2;255;160;255m";; # Alt Informational messages
        reset) color_code="\033[0m";; # Reset to default text color
        *) echo "Invalid color: $1" >&2; return 1;;
    esac
    echo -en "$color_code"
}

# Print message
print_message() {
    echo -e "$1"
}

browsers=(firefox chromium)
devtools=(gcc clang llvm make cmake ninja autoconf automake jq pkg-config meson sassc ImageMagick optipng wget curl linux-headers)
misc=(lxappearances easyeffects flameshot redshift brightnessctl)
rice=(feh dunst rofi sxhkd wmctrl xdotool)
term_apps=(alacritty wezterm zoxide zellij lazygit fzf ripgrep fd sd bat)

install_apps() {
    sudo xbps-install -S -y ${term_apps[@]} ${browsers[@]} ${devtools[@]} ${rice[@]} ${misc[@]}
}

install_brave(){
    dr=$(pwd)

    print_message "$(color lavender)Cloning brave-bin...$(color reset)"
    git clone https://github.com/soanvig/brave-bin
    cd brave-bin

    print_message "$(color lavender)Building brave-bin...$(color reset)"
    mkdir -p ~/.local/pkgs/srcpkgs/brave-bin 
    mv brave-bin/template ~/.local/pkgs/srcpkgs/brave-bin
    cd ~/.local/pkgs/srcpkgs/brave-bin
    ./xbps-src pkg brave-bin
    sudo xbps-install --repository=hostdir/binpkgs brave-bin

    cd "$dr"

    print_message "$(color green)Brave installed$(color reset)"
    clear
}

install_compfy(){
    dr=$(pwd)

    print_message "$(color lavender)Cloning compfy...$(color reset)"
    git clone https://github.com/Allusive-dev/compfy ~/


    #check deps
    deps=(MesaLib-devel dbus-devel libglvnd-devel libconfig-devel libev-devel pcre-devel
        pixman-devel xcb-util-image-devel xcb-util-renderutil-devel
        libxdg-basedir-devel uthash)

    print_message "$(color lavender)Installing deps...$(color reset)"
    sudo xbps-install -S -y ${deps[@]}

    print_message "$(color lavender)Building compfy...$(color reset)"
    cd ~/compfy

    meson setup . build
    ninja -C build
    ninja -C build install

    cd "$dr"

}

install_floorp(){

    print_message "$(color lavender)Installing floorp...$(color reset)"

    # Define variables
    dr="$(pwd)"
    download_path="$dr/floorp/floorp-linux-x86_64.tar.bz2"
    target_dir="/opt/floorp"
    icon_sizes=(32 64 128 256 512)  # Adjust icon sizes if needed

    # Download the file
    curl -JL https://github.com/Floorp-Projects/Floorp/releases/download/v11.9.0/floorp-11.9.0.linux-x86_64.tar.bz2 -o "$download_path"


    cd "$dr/floorp"
    tar -xf floorp-linux-x86_64.tar.bz2

    # Move app files
    mv "$dr/floorp" "$target_dir"

    # Resize and move icons
    for i in "${icon_sizes[@]}"; do
        local _icon_dest="/usr/share/icons/hicolor/${i}x${i}/apps"
        install -dm755 "$_icon_dest"
        convert -resize ${i}x${i} "./floorp/floorp.png" "$_icon_dest/floorp.png"
        optipng "$_icon_dest/floorp.png"
        chmod 644 "$_icon_dest/floorp.png"
    done

    # Move desktop file
    cp -f "./floorp/floorp.desktop" "/usr/share/applications/"

    ln -sf "$target_dir/floorp" /usr/bin/

    print_message "$(color green)Floorp installed$(color reset)"
}

#install_apps
install_floorp



