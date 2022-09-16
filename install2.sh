#!/bin/bash

# Videódriver + Grafikus felület + Billentyűzet + Mouse + Intel proci javításai
apt install -y xorg xserver-xorg-video-intel xserver-xorg-video-nouveau xserver-xorg-core xserver-xorg-input-synaptics xserver-xorg-input-mouse xserver-xorg-input-libinput xserver-xorg-input-kbd xinit xfonts-encodings va-driver-all intel-microcode

# Hálózatkezelés
apt install -y network-manager network-manager-openvpn network-manager-gnome

# Hangkeltés + bluetooth
apt install -y pulseaudio pavucontrol pulseaudio-module-bluetooth blueman

# Ablakezelő szoftver és kiegészítései
apt install -y bspwm sxhkd i3lock xautolock xclip rofi polybar dunst libnotify-bin

# Fontok
apt install -y fonts-font-awesome fonts-hack-ttf fonts-ubuntu fonts-roboto fonts-dejavu

# Filekezelő program és kiegészítései
apt install -y vifm trash-cli fuse-zip curlftpfs sshfs go-mtpfs libmtp-common mediainfo archivemount 

# Programok
apt install -y imagemagick imv libreoffice-gtk3 libreoffice-l10n-hu transmission-gtk gnome-calculator mpv grsync htop google-chrome-stable inxi micro

# Fordításokhoz szükséges
apt install -y libxft-dev build-essential fonts-fantasque-sans cmake

# Egyéb
apt install -y zip unzip unrar zstd fzf exa neofetch psmisc wget traceroute man-db bash-completion adb fastboot dbus-x11 ntfs-3g gnome-keyring policykit-1-gnome xbacklight ffmpeg git rsync 

# GTK programok ezzel a csomaggal lassan indulnak el
apt autoremove -y xdg-desktop-portal-gtk

#Szükségtelen programok eltávolítása
apt autoremove –-purge -y nano vim xterm
