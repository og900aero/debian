#!/bin/bash

apt update; apt install sudo
usermod -aG sudo shyciii

apt install gpg -y
cat << EOF > /etc/apt/sources.list.d/google-chrome.list
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
EOF

wget -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google.gpg
apt update

mkdir -p /home/Data
chmod 744 /home/Data
sed -i 's/errors=remount-ro/defaults,relatime/g' /mnt/etc/fstab
echo "/dev/sda3 /home/Data ext4 defaults,relatime 0 2" >> /etc/fstab

echo "vm.swappiness=10" >> /etc/sysctl.d/local.conf

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

echo "MaxRetentionSec=15day" >> /etc/systemd/journald.conf"

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
