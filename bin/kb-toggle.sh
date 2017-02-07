#!/bin/sh

STATUSFILE=/tmp/kb-toggled
if [ -f ${STATUSFILE} ]; then
#	xmodmap -e 'keycode 62 = Shift_R' &&
#	xmodmap -e 'keycode 114 = Right' &&
	xmodmap -e 'keycode 118 = Insert NoSymbol Insert' &&
	xmodmap -e 'keycode 119 = Delete NoSymbol Delete' &&
	rm -f ${STATUSFILE}
else
#	xmodmap -e 'keycode 62 = Prior' &&
#	xmodmap -e 'keycode 114 = Next' &&
	xmodmap -e 'keycode 118 = Prior NoSymbol Prior' &&
	xmodmap -e 'keycode 119 = Next NoSymbol Next' &&
	touch ${STATUSFILE}
fi
