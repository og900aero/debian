#!/bin/bash

# Videódriver + Grafikus felület + Billentyűzet + Mouse + Intel proci javításai
apt install -y xorg xserver-xorg-video-intel xserver-xorg-core xserver-xorg-input-synaptics xserver-xorg-input-mouse xserver-xorg-input-libinput xserver-xorg-input-kbd xinit xfonts-encodings va-driver-all intel-microcode

# Hálózatkezelés
apt install -y network-manager network-manager-openvpn network-manager-gnome

# Hangkeltés + bluetooth
apt install -y pulseaudio pavucontrol
# pulseaudio-module-bluetooth blueman

# Ablakezelő szoftver és kiegészítései
apt install -y bspwm sxhkd i3lock xautolock xclip rofi polybar dunst libnotify-bin

# Fontok
apt install -y fonts-font-awesome fonts-hack-ttf fonts-ubuntu fonts-roboto fonts-dejavu

# Filekezelőprogram és kiegészítései
apt install -y vifm ranger trash-cli fuse-zip curlftpfs sshfs android-file-transfer mediainfo archivemount zip unzip unrar zstd poppler-utils

# Programok
apt install -y imagemagick imv libreoffice libreoffice-l10n-hu transmission-gtk gnome-calculator mpv rsync grsync htop google-chrome-stable inxi ffmpeg

# Fordításokhoz szükséges
apt install -y libxft-dev build-essential cmake

# Egyéb
apt install -y laptop-mode-tools firmware-misc-nonfree cuetools shntool flac fzf exa neofetch psmisc wget traceroute man-db bash-completion adb fastboot dbus-x11 ntfs-3g gnome-keyring policykit-1-gnome xbacklight heif-gdk-pixbuf git curl bc x11-apps

# GTK programok ezzel a csomaggal lassan indulnak el
apt purge -y xdg-desktop-portal-gtk

# Szükségtelen programok eltávolítása
apt autoremove --purge -y vim xterm nano exim4-base youtube-dl vim-common firebird3.0-common bluez acpid
