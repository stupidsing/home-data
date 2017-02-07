#!/bin/sh
# now called by /etc/rc.local

pkill -f wpa_supplicant
{
echo 'network={'
echo 'ssid="ywsing"'
echo 'psk=""'
echo 'key_mgmt=WPA-PSK'
echo '}'
} > /tmp/wpa_supplicant.conf

/sbin/wpa_supplicant -iwlan0 -c/tmp/wpa_supplicant.conf &
/sbin/dhclient wlan0 &
