#!/bin/bash

USBDIR=/tmp/media/a7b2cf3d-37d7-40e1-960c-a5f30522cb1a/
OPTIONS="-avz --size-only --delete --delete-excluded"

MOUNTDIR=`dirname ${USBDIR}`

mkdir ${MOUNTDIR} 
sshfs 192.168.1.10:/media ${MOUNTDIR}

sudo rsync ${OPTIONS} ~/ ${USBDIR}/ubuntu/ \
	--exclude *.iso \
	--exclude *.vdi \
	--exclude .gconf \
	--exclude .gconfd \
	--exclude .gnome2 \
	--exclude .gvfs \
	--exclude .local \
	--exclude .macromedia \
	--exclude .mozilla \
	--exclude .thumbnails \
	--exclude .thunderbird \
	--exclude .wine
sudo rsync ${OPTIONS} /root/ ${USBDIR}/root/
sudo rsync ${OPTIONS} /data/ ${USBDIR}/data/ --exclude *.vdi --exclude wine

# Mount parents' machine to back up
sudo mount.cifs //192.168.1.7/Users /mnt -o user=ywsing,password=fong52,iocharset=utf8 \
&& (
	sudo rsync ${OPTIONS} /mnt/User/Desktop/ ${USBDIR}/parents/
)

rmdir ${MOUNTDIR}
