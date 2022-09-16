#!/bin/bash

apt update; apt install sudo
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

# USB Driveok automountja
cd /home/Data/Linux/Compile/automount-usb
sh configure.sh

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
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf

# Suckless Terminal telepítése
cd /home/Data/Linux/Compile/st-0.8.5-debian
make clean install

# Saját config fileok visszaállítása
mkdir -p /home/shyciii/mnt/android /home/shyciii/mnt/ftp /home/shyciii/mnt/ssh
tar -xvf /home/Data/Linux/Backup/home_backup_debian.tar.zst --directory /home/shyciii
chown -R shyciii:users /home/shyciii/
