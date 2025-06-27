#!/usr/bin/env bash

ifdown wlp0s20f3
head -n -5 /etc/network/interfaces > tmp.txt && mv tmp.txt /etc/network/interfaces
ip link set dev wlp0s20f3 down
ip link set dev wlp0s20f3 up
iwlist wlp0s20f3 scan | grep ESSID
read -p "Add meg a Wi-Fi ESSID-t: " ESSID
read -s -p "Add meg a Wi-Fi jelszót: " PASS
echo
wpa_passphrase "$ESSID" "$PASS" | tee /etc/wpa_supplicant.conf > /dev/null
wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp0s20f3
dhclient wlp0s20f3
