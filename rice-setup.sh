#!/bin/bash

#Scripted by GPI..

#Installing nvidia-drivers 
current_directory="$PWD"

read -rep $'[\e[1;33mACTION\e[0m] - Wanna install reflector and update your packages and pacman configuration? (y,n) ' REF
if [[ $REF == "Y" || $REF == "y" ]]; then
    sudo cp pacman.conf /etc/pacman.conf
    sudo pacman -S reflector
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    sudo reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    sudo pacman -Syu
fi 

nvidia_stage=(
    linux-headers 
    nvidia-dkms 
    nvidia-settings 
    libva 
    libva-nvidia-driver-git
)

read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install Nvidia-drivers? (y,n) ' ANS
if [[ $ANS == "Y" || $ANS == "y" ]]; then
    if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
        ISNVIDIA=true
    else
        ISNVIDIA=false
    fi
    read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install the packages? (y,n) ' INST
    if [[ $INST == "Y" || $INST == "y" ]]; then
        # Setup Nvidia if it was found
        if [[ "$ISNVIDIA" == true ]]; then
            echo -e "$CNT - Nvidia GPU support setup stage, this may take a while..."
            for SOFTWR in ${nvidia_stage[@]}; do
                install_software $SOFTWR
            done
        
            # update config
            sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
            sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
            echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>> $INSTLOG
        fi
    fi
fi

# Installing wifi card Driver
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install TP Link chipset driver? (y,n) ' CHI
if [[ $CHI == "y" || $CHI == "Y" ]]; then
    sudo pacman -S linux-headers git
    cd /opt
    sudo git clone https://github.com/RinCat/RTL88x2BU-Linux-Driver.git
    cd /opt/RTL88x*
    sudo make && sudo make install
    modprobe 88x2bu
fi

#Installing the Window Manager
read -rep $'[\e[1;33mACTION\e[0m] - What desktop would you like to install? (x=xfce4,g=gnome,s=sway(with dotfiles),n=skip) ' DESK
cd $current_directory
if [[ $DESK == "x" || $DESK == "X" ]]; then
    sudo pacman -S xfce4 xfce4-goodies lightdm
    sudo systemctl enable lightdm
elif [[ $DESK == "g" || $DESK == "G" ]]; then
    sudo pacman -S gnome gnome-extra
    sudo systemctl enable gdm
elif [[ $DESK == "s" || $DESK == "s" ]]; then
    sudo pacman -S sway swaybg polkit wofi waybar bluez bluez-utils blueman ttf-roboto-mono ranger alacritty adobe-source-code-pro-fonts thunar git sddm brightnessctl eog xorg-xwayland pulseaudio pulseaudio-bluetooth 
    #For automount in thunar
    sudo pacman -S gvfs thunar-volman gvfs-mtp #mtp is for mobile
    systemctl --user enable pulseaudio.service 
    systemctl --user enable pulseaudio.socket
    sudo systemctl enable bluetooth 
    #Configuration of Dotfiles
    mkdir -p ~/.config 
    cp -r {sway,alacritty,waybar,wofi} ~/.config/. 
    sudo cp bash.bashrc /etc/bash.bashrc
    sudo cp pacman.conf /etc/pacman.conf
fi

#Installing Additional software
software=(
    man
    git
    neofetch
    reflector
    pkgfile
    command-not-found
    tar
    htop
    btop
    code
    gzip
    lzip
    bzip3
    bzip2
    zip
    p7zip
    unrar
    gimp
    kdenlive
    zip
    unzip
    plocate
    ufw
    chromium
    firefox
    telegram-desktop
    vlc
    virt-manager
    virt-viewer
    dnsmasq
    vde2
    bridge-utils
    openbsd-netcat
    libguestfs
    obsidian
    tor
    torbrowser-launcher
    libreoffice-still
)

AUR_pkgs=(
    vscodium
    onlyoffice-bin
    swaylock-effects
)

cd $current_directory

read -rep $'[\e[1;33mACTION\e[0m] - Would you like to Some additional software? (y,n) ' SOF
if [[ $SOF == "y" || $SOF == "Y" ]]; then
    for SOFTWR in ${software[@]}; do
        sudo pacman -S $SOFTWR
    done
    sudo curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
    echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
    sudo pacman -Syu sublime-text
    sudo systemctl enable --now ufw
    sudo ufw enable
    updatedb
    sudo pacman -S plocate
    sudo systemctl enable --now plocate-updatedb.timer
    sudo systemctl enable --now libvirtd
    sudo usermod -aG libvirt $USER
    sudo cp libvirtd.conf /etc/libvirtd/libvirtd.conf 
    sudo cp bash.bashrc /etc/bash.bashrc
    sudo pkgfile -u
fi 

read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install AUR packages using PARU? (y,n) ' AUR
if [[ $AUR == "y" || $AUR == "Y" ]]; then
    cp /opt
    sudo pacman -S --needed base-devel
    sudo git clone https://aur.archlinux.org/paru.git
    cd paru
    sudo makepkg -si
    for SOFTWR in ${AUR_pkgs[@]}; do
        paru -S $SOFTWR
    done
    echo "Now better Reboot ! And hope it works."
fi

#Blackarch on top?
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install blackarch tools? (y,n) ' BLA
if [[ $BLA == "y" || $BLA == "Y" ]]; then
    curl -O https://blackarch.org/strap.sh
    echo 5ea40d49ecd14c2e024deecf90605426db97ea0c strap.sh | sha1sum -c
    chmod +x strap.sh
    sudo ./strap.sh
    # Make sure to enable multilib for 32 bit binaries in pacman.conf. Its already dont in my configuration
    sudo pacman -Syu
    sudo pacman -S blackarch
else
    echo "Now better Reboot ! And hope it works."
    exit
fi


