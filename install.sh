#!/bin/bash

apt update; apt upgrade -y; apt install -y sudo
usermod -aG sudo shyciii

# Add contrib, non-free
apt install -y software-properties-common
apt-add-repository -y contrib non-free non-free-firmware

# Hangkeltés + bluetooth
apt install -y pulseaudio pavucontrol

# Ablakezelő szoftver és kiegészítései
apt install -y i3lock xautolock xclip rofi dunst libnotify-bin bspwm sxhkd polybar acpi yad

# Fontok
apt install -y fonts-font-awesome fonts-dejavu ttf-mscorefonts-installer

# Filekezelőprogram és kiegészítései
apt install -y unrar-free libfuse3-3 ifuse sshfs mediainfo zip unzip zstd 7zip poppler-utils ffmpegthumbnailer xlsx2csv bat catdoc docx2txt jq libimage-exiftool-perl

# Programok
apt install -y imagemagick imv libreoffice libreoffice-l10n-hu transmission-gtk gnome-calculator mpv rsync grsync btop inxi ffmpeg ncdu
#update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 100

# Fordításokhoz szükséges
apt install -y libxft-dev build-essential cmake make pkg-config fontconfig

# Egyéb
apt install -y testdisk gpg duf tldr ripgrep xdotool pmount freerdp2-x11 libsecret-tools firmware-misc-nonfree wmctrl cuetools shntool flac maim exa psmisc wget traceroute man-db bash-completion dbus-x11 ntfs-3g gnome-keyring policykit-1-gnome light heif-gdk-pixbuf git curl bc x11-apps

# Micro text editor telepítése
cd /usr/local/bin
curl https://getmic.ro | bash
cd /
update-alternatives --install /usr/bin/editor editor /usr/local/bin/micro 100

# SSHRC telepítése
#wget https://raw.githubusercontent.com/cdown/sshrc/master/sshrc
#chmod +x sshrc
#mv sshrc /usr/local/bin

# Androidhoz
# apt install -y adb fastboot android-file-transfer

# Chrome telepítéshez szükséges csomaglista létrehozása
cat <<'EOF' > /etc/apt/sources.list.d/google-chrome.list
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
EOF
wget -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google.gpg
apt update
apt install -y google-chrome-stable

# Ueberzugpp telepítése
echo 'deb http://download.opensuse.org/repositories/home:/justkidding/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:justkidding.list
curl -fsSL https://download.opensuse.org/repositories/home:justkidding/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_justkidding.gpg > /dev/null
apt update
apt install -y ueberzugpp

# Eza telepítése
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
apt update
apt install -y eza

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
echo "vm.vfs_cache_pressure=75" >> /etc/sysctl.d/local.conf
echo "kernel.nmi_watchdog=0" >> /etc/sysctl.d/local.conf
# 4GB memória miatt (8GB memória esetén 5 legyen)
echo "vm.dirty_ratio=10" >> /etc/sysctl.d/local.conf
# 4GB memória miatt (8GB memória esetén 3 legyen)
echo "vm.dirty_background_ratio=10" >> /etc/sysctl.d/local.conf
membycore=$(echo $(( $(vmstat -s | head -n1 | awk '{print $1;}')/$(nproc) )))
bestkeepfree=$(echo "scale=0; "$membycore"*0.058" | bc | awk '{printf "%.0f\n", $1}');
bestkeepfree=$(echo "$membycore * 0.058" | bc | awk '{printf "%.0f\n", $1}')
echo "vm.min_free_kbytes=$bestkeepfree" >> /etc/sysctl.d/local.conf

# Videódriver + Grafikus felület + Billentyűzet + Mouse + Intel proci javításai
apt install -y xorg xserver-xorg-video-intel xserver-xorg-core xserver-xorg-input-synaptics xserver-xorg-input-mouse xserver-xorg-input-libinput xserver-xorg-input-kbd xinit xfonts-encodings intel-media-va-driver intel-microcode

# Intel driver beállítása
cat <<'EOF' > /etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "TearFree" "true"
    Option "TripleBuffer" "true"
EndSection
EOF

# Naplózás beállítása
echo "MaxRetentionSec=15day" >> /etc/systemd/journald.conf

# Notebook-hoz double tap beállítása
cat <<'EOF' > /etc/X11/xorg.conf.d/40-libinput.conf
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

# Alvás után legyen képernyő zárolása
cat <<'EOF' > /etc/systemd/system/suspend@.service
[Unit]
Description=User suspend actions
Before=sleep.target

[Service]
User=shyciii
Type=forking
Environment=DISPLAY=:0
ExecStart=/bin/sh -c '/usr/bin/i3lock -i ~/Pictures/Meghan.png'

[Install]
WantedBy=sleep.target
EOF
systemctl enable suspend@service
systemctl start suspend@service

# Szolgáltatások letiltása
systemctl mask suspend-then-hibernate.target hibernate.target hybrid-sleep.target

# DWM telepítése
#apt install -y libx11-xcb-dev libxcb-res0-dev libxinerama-dev libxcb-util-dev
#cd /home/Data/Linux/Compile/dwm
#rm config.h
#make clean install

# Fastfetch telepítése
wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.28.0/fastfetch-linux-amd64.deb
apt install -y ./fastfetch-linux-amd64.deb
rm -rf fastfetch-linux-amd64.deb

# BSLayout telepítése
curl https://raw.githubusercontent.com/phenax/bsp-layout/master/install.sh | bash -;

# lf telepítése
#apt install -y golang
#env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest
#apt autoremove --purge -y golang
#cp /root/go/bin/lf /usr/local/bin
#rm -rf /root/go

# yazi telepítése
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#rustup update
#git clone https://github.com/sxyazi/yazi.git
#cd yazi/
#cargo build --release
#cp target/release/yazi /usr/local/bin/yazi
#ya pack -a yazi-rs/plugins#full-border
#ya pack -a yazi-rs/plugins#chmod
#ya pack -a yazi-rs/plugins#hide-preview
#ya pack -a yazi-rs/plugins#max-preview
#ya pack -a yazi-rs/plugins#smart-filter
#ya pack -a yazi-rs/plugins#jump-to-char
#ya pack -a dawsers/dual-pane
#ya pack -a dawsers/fuse-archive
#ya pack -a KKV9/compress
#ya pack -a TD-Sky/sudo

# USB Driveok automountja
cd /home/Data/Linux/Compile/automount-usb
bash configure.sh

# Jogosultság sima usernek a fusemount csatolásakor
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# Tűzfal konfigurálása
cat <<'EOF' > /etc/nftables.conf
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

                         # SMB
			 ip saddr 192.168.0.0/24 tcp dport { 139, 445 } ct state new accept	
			 ip saddr 192.168.0.0/24 udp dport { 137, 138 }	ct state new accept
	
	}
	chain forward {
		type filter hook forward priority 0; policy drop;
	}
}
EOF
systemctl enable nftables.service
systemctl start nftables.service

# Saját config fileok visszaállítása
#mkdir -p /home/shyciii/mnt/android /home/shyciii/mnt/ftp /home/shyciii/mnt/ssh
tar -xvf /home/Data/Linux/Backup/home_backup_debian.tar.zst --directory /home/shyciii
chown -R shyciii:users /home/shyciii/
cp -r /home/shyciii/.config/lf /root/.config/
cp -r /home/shyciii/.config/micro /root/.config/
cp -r /home/shyciii/usr/local/bin/* /usr/local/bin
rm -rf /home/shyciii/usr
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/st 100
#update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 100

# Nano config file beállítása a root usernek
#mkdir /root/.config/nano
#cp /home/shyciii/.config/nano/nanorc /root/.config/nano

# Trash beállítása
mkdir /home/Data/.Trash
chmod a+rw /home/Data/.Trash
chmod +t /home/Data/.Trash

# Delta telepítése (diff program helyett)
wget https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb
apt install -y ./git-delta_0.18.2_amd64.deb
rm -rf git-delta_0.18.2_amd64.deb

# Printing
apt install -y cups system-config-printer printer-driver-escpr
usermod -aG lp,lpadmin shyciii

# SMB telepítése
apt install -y samba cifs-utils
cat <<'EOF' > /etc/samba/smb.conf
[global]

   workgroup = WORKGROUP
   vfs object = fruit streams_xattr
   fruit:copyfile = yes

[Downloads]

   comment = iphone share
   path = /home/shyciii/Downloads
   writable = yes
   valid users = shyciii
   guest ok = no
   browseable = yes
   create mask = 0644
   directory mask = 0744
EOF
#smbpasswd -a shyciii
echo "shyciii" | sudo smbpasswd -s -a shyciii
echo "A folyamat végén módosítsd a shyciii smbuser jelszavát!"
mkdir /home/shyciii/Downloads
chmod 750 /home/shyciii/Downloads/
chown shyciii:shyciii /home/shyciii/Downloads/
systemctl restart smbd.service

# GTK programok ezzel a csomaggal lassan indulnak el
apt purge -y xdg-desktop-portal-gtk

# Szükségtelen programok eltávolítása
apt autoremove --purge -y nano vim-common firebird3.0-common bluez laptop-mode-tools laptop-detect

# Hálózatkezelés
apt install -y network-manager network-manager-gnome network-manager-openvpn network-manager-openvpn-gnome
head -n -5 /etc/network/interfaces > tmp.txt && mv tmp.txt /etc/network/interfaces

# Wifi lekapcsolása, ha ethernet kábel csatlakoztatva van
cat <<'EOF' > /etc/NetworkManager/dispatcher.d/70-wifi-wired-exclusive.sh
#!/bin/bash
export LC_ALL=C

enable_disable_wifi ()
{
    result=$(nmcli dev | grep "ethernet" | grep -w "connected")
    if [ -n "$result" ]; then
        nmcli radio wifi off
    else
        nmcli radio wifi on
    fi
}

if [ "$2" = "up" ]; then
    enable_disable_wifi
fi

if [ "$2" = "down" ]; then
    enable_disable_wifi
fi
EOF
chown root:root /etc/NetworkManager/dispatcher.d/70-wifi-wired-exclusive.sh
chmod 744 /etc/NetworkManager/dispatcher.d/70-wifi-wired-exclusive.sh
systemctl restart NetworkManager

# Névfeloldás gyorsítása
cat <<'EOF' > /etc/NetworkManager/NetworkManager.conf
[main]
plugins=ifupdown,keyfile
dns=none
systemd-resolved=false

[ifupdown]
managed=false
EOF
cat <<'EOF' > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
chattr +i /etc/resolv.conf

# Default programok root alatt
cat <<'EOF' > /root/.bashrc
export VISUAL=micro
export EDITOR=micro
EOF

# SSH kliens erősebb biztonsági beállítása
cat <<'EOF' >> /etc/ssh/ssh_config
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org
HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-ed25519
Ciphers chacha20-poly1305@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
EOF

# sudo-hoz EDITOR environment megadása
sed -i '/env_reset/a Defaults    env_keep += "EDITOR"' /etc/sudoers

# Adott user jelszó nélküli restart, shutdown lehetősége
# echo "shyciii ALL=(ALL) NOPASSWD: /sbin/shutdown, /sbin/reboot, /bin/rmdir" >> /etc/sudoers
echo "shyciii ALL=(ALL) NOPASSWD: /bin/rmdir, /usr/bin/umount" >> /etc/sudoers

# Enable BBR network congestion
echo "net.core.default_qdisc = fq" >> /etc/sysctl.d/local.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.d/local.conf
# Other sysctl config
echo "net.core.rmem_max=4194304" >> /etc/sysctl.d/local.conf
echo "net.core.wmem_max=1048576" >> /etc/sysctl.d/local.conf
sysctl --system

# Oh-my-posh telepítése
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

# Gnome-keyring automatikus kinyitása belépéskor
sed -i '96s/^/\nauth       optional     pam_gnome_keyring.so\nsession    optional     pam_gnome_keyring.so auto_start\n/' /etc/pam.d/login

# Performance support engedélyezése
#crontab -l > mycron
#echo "@reboot /sbin/sysctl -q -w dev.i915.perf_stream_paranoid=0" >> mycron
#crontab mycron
#rm mycron

#update-desktop-database /home/shciii/.local/share/applications
# Fényerő beállítása 75%-ra
light -S 75

# Hangerő beállítása 50%-ra
pactl set-sink-volume @DEFAULT_SINK@ 50%

mkdir /mnt/sshfs
chown shyciii:shyciii /mnt/sshfs

echo "Jelentkezz be a felhasználóddal, és add ki a következő parancsot:"
echo "secret-tool store --label="RDP Password" rdp-server ipcim username felhasznalonev"
