#!/usr/bin/env bash

ifdown wlp0s20f3
sleep 3
head -n -5 /etc/network/interfaces > tmp.txt && mv tmp.txt /etc/network/interfaces
sleep 2
head -n -5 /etc/network/interfaces > tmp.txt && mv tmp.txt /etc/network/interfaces
sleep 2
systemctl restart networking
sleep 3
ip link set dev wlp0s20f3 down
sleep 2
ip link set dev wlp0s20f3 up
sleep 3
iwlist wlp0s20f3 scan | grep ESSID
read -p "Add meg a Wi-Fi ESSID-jét: " ESSID
read -s -p "Add meg a Wi-Fi jelszavát: " PASS
echo
wpa_passphrase "$ESSID" "$PASS" | tee /etc/wpa_supplicant.conf > /dev/null
sleep 2
wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp0s20f3
sleep 3
dhclient wlp0s20f3
