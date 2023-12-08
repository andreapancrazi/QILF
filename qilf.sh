#!/bin/bash

# Array to keep track of packages that couldn't be installed
failed_packages=()

# Function to install a package if not already installed
install_package() {
    package_name=$1
    package_manager=$2
    additional_flags=$3

    echo "Checking if $package_name is installed..."

    case $package_manager in
        "apt")
            # Check if the package is available through apt
            if sudo apt-get install -yq $package_name; then
                echo "$package_name installed successfully using apt."
            else
                echo "Error installing $package_name."
                failed_packages+=($package_name)
            fi
            ;;
        "snap")
            # Install the Snap package with additional flags if provided
            if sudo snap install $package_name $additional_flags; then
                echo "$package_name installed successfully using snap."
            else
                echo "Error installing $package_name."
                failed_packages+=($package_name)
            fi
            ;;
        *)
            echo "Unsupported package manager: $package_manager"
            ;;
    esac
}

# Get the username of the user who executed the script with sudo
current_user=$(logname)

# Download wallpaper from Imgur
wallpaper_url="https://i.imgur.com/RWLF8bD.jpeg"
wget -O /usr/share/backgrounds/SBKjnxm.jpg $wallpaper_url

# Install zsh and oh-my-zsh
install_package zsh apt

# Set zsh as the default shell
chsh -s $(which zsh)

# Install Oh My Zsh without user interaction
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"

# Download and use the Kali Linux zshrc file
curl -o /home/$current_user/.zshrc https://gitlab.com/kalilinux/packages/kali-defaults/-/raw/kali/master/etc/skel/.zshrc

# Install other essential tools and applications
install_package tmux apt
install_package vim apt
install_package htop apt
install_package inxi apt
install_package neofetch apt
install_package flameshot apt
install_package gnome-tweaks

# Install Obsidian, draw.io, Visual Studio Code, Zoom, VirtualBox, and VLC
install_package obsidian snap
install_package drawio snap
install_package code snap --classic
install_package zoom-client snap
install_package vlc snap

# Install VirtualBox
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" > /etc/apt/sources.list.d/virtualbox.list'
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
sudo apt-get update
install_package virtualbox-6.1 apt

# Set Dark Theme and Wallpaper
gsettings set org.gnome.shell.ubuntu color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.background picture-uri-dark "file:///usr/share/backgrounds/SBKjnxm.jpg"

# Display a list of packages that couldn't be installed
if [ ${#failed_packages[@]} -eq 0 ]; then
    echo "All packages installed successfully."
else
    echo "The following packages couldn't be installed:"
    for package in "${failed_packages[@]}"; do
        echo "- $package"
    done
fi

echo "Installation complete!"