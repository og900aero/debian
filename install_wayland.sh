#!/bin/bash

set -x

# log all commands
exec > >(tee -a "output.log") 2>&1

apt update && apt upgrade -y && apt install -y sudo curl
usermod -aG sudo shyciii

# Add contrib, non-free non-free-firmware
#cat <<EOF >/etc/apt/sources.list
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOF

# Enable backports
echo "deb http://deb.debian.org/debian trixie-backports main" | tee -a /etc/apt/sources.list
apt update

# Sound and bluetooth
apt install -y pipewire-audio pipewire-pulse wireplumber pavucontrol

# Window management software and add-ons
apt install -y xwayland swaylock dunst libnotify-bin rofi acpi brightnessctl clipman swaybg swayimg grim slurp wf-recorder

# Fonts
apt install -y fonts-font-awesome fonts-dejavu fonts-noto-color-emoji
# apt install -y font-manager

# File manager add-ons
apt install -y unrar-free libfuse3-4 ifuse sshfs mediainfo zip unzip zstd 7zip poppler-utils ffmpegthumbnailer xlsx2csv bat catdoc docx2txt jq libimage-exiftool-perl chafa

# Other programs
apt install -y v imagemagick libreoffice libreoffice-l10n-hu transmission-gtk gnome-calculator mpv rsync grsync btop inxi ffmpeg ncdu zoxide fastfetch fd-find udiskie

# For compiles
apt install -y libxft-dev build-essential cmake make pkg-config fontconfig libxinerama-dev libxcb-res0 libgtkmm-3.0-dev libimlib2-dev libdbus-1-dev libx11-xcb-dev libxcb-res0-dev libyajl-dev libevent-dev bison ncurses-dev libxcb-util-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-cursor-dev libxcb-xinerama0-dev automake 

# Others
apt install -y apt-file testdisk duf tealdeer ripgrep git-delta freerdp3-x11 libsecret-tools cuetools shntool flac eza psmisc gnome-keyring heif-gdk-pixbuf bc zenity
apt-file update

# Install LocalSend
wget https://github.com/localsend/localsend/releases/download/v1.17.0/LocalSend-1.17.0-linux-x86-64.deb
dpkg -i LocalSend-1.17.0-linux-x86-64.deb
rm -rf LocalSend-1.17.0-linux-x86-64.deb
sudo apt install -f

wget -qO /usr/share/keyrings/google-linux-signing-key.gpg https://dl.google.com/linux/linux_signing_key.pub
cat <<EOF > /etc/apt/sources.list.d/google-chrome.list
deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-key.gpg] http://dl.google.com/linux/chrome/deb/ stable main
EOF
apt update
apt install -y google-chrome-stable

# Mount Data partition and privilege settings
mkdir -p /home/Data
chmod 744 /home/Data
chown shyciii:users /home/Data
#mount "$PARTITION"

# Modify fstab
sed -i 's/errors=remount-ro/defaults,relatime/g' /etc/fstab
sed -i 's/home\/Data      ext4    defaults/home\/Data      ext4    defaults,relatime/g' /etc/fstab
#echo "$PARTITION      /home/Data      ext4     defaults,relatime    0    2" >> /etc/fstab

# Modify grub timeout
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=2/g' /etc/default/grub
sed -i 's/quiet/loglevel=3/g' /etc/default/grub
update-grub

# Create and set swap file
dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile     none     swap    sw    0    0" >> /etc/fstab

# Enable BBR network congestion
echo "net.core.default_qdisc = fq" >> /etc/sysctl.d/local.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.d/local.conf

# Other sysctl config
echo "net.core.rmem_max=4194304" >> /etc/sysctl.d/local.conf
echo "net.core.wmem_max=1048576" >> /etc/sysctl.d/local.conf
echo "vm.swappiness=10" >> /etc/sysctl.d/local.conf
echo "vm.vfs_cache_pressure=75" >> /etc/sysctl.d/local.conf
echo "kernel.nmi_watchdog=0" >> /etc/sysctl.d/local.conf
echo "vm.dirty_ratio=5" >> /etc/sysctl.d/local.conf
echo "vm.dirty_background_ratio=3" >> /etc/sysctl.d/local.conf
echo "vm.min_free_kbytes=41943" >> /etc/sysctl.d/local.conf

# change log settings
echo "MaxRetentionSec=15day" >> /etc/systemd/journald.conf

# Set timeout
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf

# Set notebook's lid settings
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf

# Disable services
systemctl mask suspend-then-hibernate.target hibernate.target hybrid-sleep.target suspend.target

# Install Oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

# Eligibility for a regular user when attaching a fusemount
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# Firewall configuration
cat <<'EOF' > /etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
	chain input {
	      type filter hook input priority 0; policy drop;

	      # accept any localhost traffic
	      iif lo accept

          # Drop invalid connections
          ct state invalid drop

	      # accept traffic originated from us
	      ct state { established, related } accept
	
	      # accept neighbour discovery otherwise IPv6 connectivity breaks
	      icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept

          # SMB
          #ip saddr 192.168.0.0/24 tcp dport { 139, 445 } ct state new accept	
		  #ip saddr 192.168.0.0/24 udp dport { 137, 138 }	ct state new accept

          # Localsend
          ip saddr 192.168.0.0/24 tcp dport 53317 ct state new accept
          # Torrent
          ip daddr 192.168.0.0/24 tcp dport 51413 ct state new accept
          ip daddr 192.168.0.0/24 udp dport 51413 ct state new accept
	}
	chain forward {
          type filter hook forward priority 0; policy drop;
	}
	chain output {
          type filter hook output priority 0; policy accept;
	}
}
EOF
systemctl enable --now nftables.service

# Restore own config files
tar -xvf /home/Data/Linux/Backup/home_backup_debian.tar.zst --directory /home/shyciii

chown -R shyciii:users /home/shyciii/

ln -s /home/shyciii/.config/lf /root/.config/lf
cp -vr /home/shyciii/.config/micro /root/.config/
cp -vr /home/shyciii/usr/local/bin/* /usr/local/bin
rm -rfv /home/shyciii/usr

# Set default terminal emulator
#update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/alacritty 100
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/foot 100

# Set default text editor
update-alternatives --install /usr/bin/editor editor /usr/local/bin/micro 100

# Trash folder settings
mkdir -p /home/Data/.Trash
chmod a+rw /home/Data/.Trash
chmod +t /home/Data/.Trash

# Printing
apt install -y cups system-config-printer printer-driver-escpr
usermod -aG lp,lpadmin shyciii
#lpadmin -p EpsonL3060 -E -v socket://192.168.0.105:9100 -m escpr:0/cups/model/epson-inkjet-printer-escpr/Epson-L3060_Series-epson-escpr-en.ppd

# Remove GTK package, because slow down startup GTK programs
apt purge -y xdg-desktop-portal-gtk

# Remove unnecessary programs
apt autoremove --purge -y nano vim-common bluez laptop-detect

# Network management
apt install -y network-manager network-manager-gnome network-manager-openvpn network-manager-openvpn-gnome
head -n -5 /etc/network/interfaces > tmp.txt && mv tmp.txt /etc/network/interfaces

# Less boot-up time
systemctl disable NetworkManager-wait-online.service
systemctl mask NetworkManager-wait-online.service

# Turn off Wifi when an ethernet cable is connected
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

# Turn off powersafe on wifi driver
cat <<'EOF' > /etc/NetworkManager/conf.d/wifi-powersave.conf
[connection]
wifi.powersave = 2
EOF

# Custom name resolution
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

# Default programs under root user
cat <<'EOF' > /root/.bashrc
export VISUAL=micro
export EDITOR=micro
EOF

# Stronger security setting for SSH client
cat <<'EOF' >> /etc/ssh/ssh_config
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org
HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-ed25519
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
EOF

# sudo to add EDITOR environment
sed -i '/env_reset/a Defaults    env_keep += "EDITOR"' /etc/sudoers

# Possibility to restart and shutdown a given user without password
# echo "shyciii ALL=(ALL) NOPASSWD: /sbin/shutdown, /sbin/reboot, /bin/rmdir" >> /etc/sudoers
echo "shyciii ALL=(ALL) NOPASSWD: /bin/rmdir, /usr/bin/umount" >> /etc/sudoers

# Open Gnome keyring automatically on login
sed -i '96s/^/\nauth       optional     pam_gnome_keyring.so\nsession    optional     pam_gnome_keyring.so auto_start\n/' /etc/pam.d/login

#update-desktop-database /home/shciii/.local/share/applications

# Set brightness to 76%
brightnessctl set 76%

mkdir -p /mnt/sshfs
chown shyciii:shyciii /mnt/sshfs

sysctl --system

rm -rfv /usr/share/applications/btop.desktop /usr/share/applications/org.pulseaudio.pavucontrol.desktop

# Add hungary location
sed -i 's/^# *\(hu_HU\.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
#update-locale LC_TIME=hu_HU.UTF-8
update-locale

# Hyprlock PAM
cat <<'EOF' >> /etc/pam.d/hyprlock
auth      include   common-auth
account   include   common-account
EOF

set +x

echo "Jelentkezz be a felhasználóddal, és add ki a következő parancsot:"
echo "secret-tool store --label="RDP Password" rdp-server ipcim username felhasznalonev"
#echo "systemctl --user enable pipewire pipewire-pulse wireplumber"
