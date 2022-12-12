# Debian

ip link set dev wlp3s0 up

iwlist wlp3s0 scan | grep ESSID

wpa_passphrase ESSID PASS | sudo tee /etc/wpa_supplicant.conf

wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp3s0

dhclient wlp3s0

apt install -y git

git clone https://github.com/og900aero/debian

cd debian

chmod +x install.sh

./install.sh

rm -rf /etc/wpa_supplicant.conf
