#!/bin/bash

apt update; apt upgrade; apt install sudo
usermod -aG sudo shyciii

# Chrome telepítéshez szükséges csomaglista létrehozása
apt install gpg -y
cat << EOF > /etc/apt/sources.list.d/google-chrome.list
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
EOF
wget -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google.gpg
apt update

# Adat partícióm felmountlása, jogosultság beállítások
mkdir -p /home/Data
chmod 744 /home/Data
chown shyciii:users /home/Data

# Fstab módosítások
sed -i 's/errors=remount-ro/defaults,relatime/g' /mnt/etc/fstab
echo "/dev/sda3      /home/Data      ext4     defaults,relatime    0    2" >> /etc/fstab

# Swap file létrehozása, beállítása
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile     none     swap    sw    0    0" >> /etc/fstab
echo "vm.swappiness=10" >> /etc/sysctl.d/local.conf

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
echo "MaxRetentionSec=15day" >> /etc/systemd/journald.conf"

# Notebook-hoz doube tap beállítása
cat > /etc/X11/xorg.conf.d/40-libinput.conf <<EOF
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
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=suspend/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf

# Fedél lehajtásakor lockolja a kijelzőt
cat > /etc/systemd/system/suspend@.service <<EOF
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

# Alvás letiltása
# systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Suckless Terminal telepítése
cd /home/Data/Linux/Compile/st-0.8.5
make clean install
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/st 100

# BSLayout telepítése
curl https://raw.githubusercontent.com/phenax/bsp-layout/master/install.sh | bash -;

# USB Driveok automountja
cd /home/Data/Linux/Compile/automount-usb
sh configure.sh

# MTP mount engedélyezése sima usernek, jogosultság
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
mkdir -p /media/shyciii
chmod 757 /media/shyciii

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
systemctl enable nftables.service
systemctl start nftables.service

# Saját config fileok visszaállítása
mkdir -p /home/shyciii/mnt/android /home/shyciii/mnt/ftp /home/shyciii/mnt/ssh
tar -xvf /home/Data/Linux/Backup/home_backup_debian.tar.zst --directory /home/shyciii
chown -R shyciii:users /home/shyciii/

# Nano config file beállítása a root usernek
mkdir /root/.config/nano
cp /home/shyciii/.config/nano/nanorc /root/.config/nano
