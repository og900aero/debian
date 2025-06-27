# Debian

ifdown wlp0s20f3

ip link set dev wlp0s20f3 up

iwlist wlp0s20f3 scan | grep ESSID

wpa_passphrase ESSID PASS | sudo tee /etc/wpa_supplicant.conf

wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp0s20f3

dhclient wlp0s20f3

apt install -y git

git clone https://github.com/og900aero/debian

cd debian

chmod +x install.sh

./install.sh

rm -rf /etc/wpa_supplicant.conf

