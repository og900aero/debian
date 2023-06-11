#!/bin/bash

apt update; apt upgrade; apt install -y sudo
usermod -aG sudo shyciii

# Hangkeltés + bluetooth
apt install -y pulseaudio pavucontrol

# Ablakezelő szoftver és kiegészítései
apt install -y bspwm sxhkd i3lock xautolock xclip rofi polybar dunst libnotify-bin

# DWM-nek
apt install -y libx11-xcb-dev libxcb-res0-dev libxinerama-dev

# Fontok
apt install -y fonts-font-awesome fonts-hack-ttf fonts-ubuntu fonts-roboto fonts-dejavu

# Filekezelőprogram és kiegészítései
apt install -y trash-cli fuse-zip ifuse curlftpfs sshfs mediainfo archivemount zip unzip unrar zstd poppler-utils ffmpegthumbnailer docx2txt xlsx2csv bat ranger jq ueberzug ranger

# Programok
apt install -y imagemagick imv libreoffice libreoffice-l10n-hu transmission-gtk gnome-calculator mpv rsync grsync htop inxi ffmpeg micro

# Fordításokhoz szükséges
apt install -y libxft-dev build-essential cmake

# Egyéb
apt install -y ripgrep xdotool pmount freerdp2-x11 laptop-mode-tools firmware-misc-nonfree wmctrl cuetools shntool flac maim fzf exa neofetch psmisc wget traceroute man-db bash-completion dbus-x11 ntfs-3g gnome-keyring policykit-1-gnome xbacklight heif-gdk-pixbuf git curl bc x11-apps

# Androidhoz
# spt install -y adb fastboot android-file-transfer

# Micro szövegszerkesztő legfrisebb
#cd /usr/bin
#curl https://getmic.ro/r | sudo sh

# Chrome telepítéshez szükséges csomaglista létrehozása
apt install -y gpg
cat << EOF > /etc/apt/sources.list.d/google-chrome.list
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
EOF
wget -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google.gpg
apt update
apt install -y google-chrome-stable

# Adat partícióm felmountlása, jogosultság beállítások
mkdir -p /home/Data
chmod 744 /home/Data
chown shyciii:users /home/Data
mount /dev/sda3 /home/Data

# Fstab módosítások
sed -i 's/errors=remount-ro/defaults,relatime/g' /etc/fstab
echo "/dev/sda3      /home/Data      ext4     defaults,relatime    0    2" >> /etc/fstab

# Grub timeout módosítása
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=2/g' /etc/default/grub
sed -i 's/quiet/loglevel=3/g' /etc/default/grub
update-grub

# Swap file létrehozása, beállítása
dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile     none     swap    sw    0    0" >> /etc/fstab
echo "vm.swappiness=10" >> /etc/sysctl.d/local.conf

# Videódriver + Grafikus felület + Billentyűzet + Mouse + Intel proci javításai
apt install -y xorg xserver-xorg-video-intel xserver-xorg-core xserver-xorg-input-synaptics xserver-xorg-input-mouse xserver-xorg-input-libinput xserver-xorg-input-kbd xinit xfonts-encodings va-driver-all intel-microcode

# Intel driver beállítása
cat <<EOF > /etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "Backlight" "intel_backlight"
    Option "AccelMethod" "sna"
    Option "TearFree" "true"
    Option "TripleBuffer" "true"
EndSection
EOF

# Naplózás beállítása
echo "MaxRetentionSec=15day" >> /etc/systemd/journald.conf

# Notebook-hoz doube tap beállítása
cat <<EOF > /etc/X11/xorg.conf.d/40-libinput.conf
Section "InputClass"
        Identifier "libinput pointer catchall"
        MatchIsPointer "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
EndSection
Section "InputClass"
        Identifier "libinput keyboard catchall"
        MatchIsKeyboard "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
EndSection
Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        Option "Tapping" "on"
        Option "TappingButtonMap" "lmr"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
EndSection
Section "InputClass"
        Identifier "libinput touchscreen catchall"
        MatchIsTouchscreen "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
EndSection
Section "InputClass"
        Identifier "libinput tablet catchall"
        MatchIsTablet "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
EndSection
EOF

# Timeout beállítása
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf

# Notebook fedeléhez kapcsolódó események beállítása
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf

# Alvás letiltása
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Fedél lehajtásakor lockolja a kijelzőt
cat <<EOF > /etc/systemd/system/suspend@.service
[Unit]
 2 Description=User suspend action
 3 Before=sleep.target
 4
 5 [Service]
 6 User=%I
 7 Type=forking
 8 Environment=DISPLAY=:0
 9 ExecStart=/usr/bin/i3lock -i /home/shyciii/Pictures/Meghan.png
10 ExecStartPost=/usr/bin/sleep 1
11
12 [Install]
13 WantedBy=suspend.target
EOF
systemctl enable suspend@shyciii.service

# Suckless Terminal telepítése
#apt install -y make pkg-config fontconfig
cd /home/Data/Linux/Compile/st-0.9
make clean install
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/st 100

# DWM telepítése
cd /home/Data/Linux/Compile/dwm
rm config.h
make clean install

# BSLayout telepítése
#curl https://raw.githubusercontent.com/phenax/bsp-layout/master/install.sh | bash -;

# lf telepítése
#apt install -y golang
#env CGO_ENABLED=0 GO111MODULE=on go get -u -ldflags="-s -w" github.com/gokcehan/lf
#apt autoremove --purge -y golang

# Preview for lf
apt install -y libmagic-dev libssl-dev bat ffmpegthumbnailer docx2txt xlsx2csv
git clone https://github.com/NikitaIvanovV/ctpv
cd ctpv
make install
cd ..
rm -rf ctpv

# USB Driveok automountja
cd /home/Data/Linux/Compile/automount-usb
bash configure.sh

# MTP mount engedélyezése sima usernek, jogosultság
#sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
#mkdir -p /media/shyciii
#chmod 757 /media/shyciii

# Tűzfal konfigurálása
cat <<EOF > /etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
	chain input {
	                 type filter hook input priority 0; policy drop;
	
	                 # accept any localhost traffic
	                 iif lo accept
	
	                 # accept traffic originated from us
	                 ct state established,related accept
	
	                 # accept neighbour discovery otherwise IPv6 connectivity breaks
	                 icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept
	
	}
	chain forward {
		type filter hook forward priority 0; policy drop;
	}
}
EOF
#systemctl enable nftables.service
#systemctl start nftables.service

# Saját config fileok visszaállítása
#mkdir -p /home/shyciii/mnt/android /home/shyciii/mnt/ftp /home/shyciii/mnt/ssh
tar -xvf /home/Data/Linux/Backup/home_backup_debian.tar.zst --directory /home/shyciii
chown -R shyciii:users /home/shyciii/

# Nano config file beállítása a root usernek
#mkdir /root/.config/nano
#cp /home/shyciii/.config/nano/nanorc /root/.config/nano

# Trash mappa beállítása
mkdir /home/Data/.Trash
chmod a+rw /home/Data/.Trash
chmod +t /home/Data/.Trash

# Xanmod kernel 5.15 telepítése
#echo 'deb http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-kernel.list
#wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
#apt update
#apt install -y linux-xanmod-lts

# Install joshuto
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#source "$HOME/.cargo/env"
#git clone https://github.com/kamiyaa/joshuto.git
#cd joshuto
#cargo install --git https://github.com/kamiyaa/joshuto.git --force

# Printing
apt install -y cups system-config-printer printer-driver-escpr
usermod -aG lp,lpadmin shyciii

# SMB telepítése
apt install -y samba
cat <<EOF > /etc/samba/smb.conf
[global]

   workgroup = WORKGROUP
   log file = /var/log/samba/log.%m
   max log size = 1000
   logging = file

[Downloads]

   comment = iphone share
   path = /home/shyciii/Downloads
   writable = yes
   guest ok = no
   browseable = yes
   create mask = 0644
   directory mask = 0744
EOF
smbpasswd -a shyciii
systemctl restart smbd.service

# GTK programok ezzel a csomaggal lassan indulnak el
apt purge -y xdg-desktop-portal-gtk

# Szükségtelen programok eltávolítása
apt autoremove --purge -y vim nano exim4-base youtube-dl vim-common firebird3.0-common bluez acpid

# Hálózatkezelés
apt install -y network-manager network-manager-openvpn network-manager-gnome

# Névfeloldás gyorsítása
cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
plugins=ifupdown,keyfile
dns=none
systemd-resolved=false

[ifupdown]
managed=false
EOF
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
chattr +i /etc/resolv.conf

# Default programok root alatt
cat <<EOF > /root/.bashrc
export VISUAL=micro
export EDITOR=micro
EOF

# sudo-hoz EDITOR environment megadása
sed -i '/env_reset/a Defaults    env_keep += "EDITOR"' /etc/sudoers

# Adott user jelszó nélküli restart, shutdown lehetősége
echo "shyciii ALL=(ALL) NOPASSWD: /sbin/shutdown, /sbin/reboot" >> /etc/sudoers

# Performance support engedélyezése
crontab -l > mycron
echo "@reboot /sbin/sysctl -q -w dev.i915.perf_stream_paranoid=0" >> mycron
crontab mycron
rm mycron

nmcli connection import type openvpn file /home/shyciii/.ssh/nyiroviktorlaptop2.ovpn
