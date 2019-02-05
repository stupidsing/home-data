#!/bin/sh

PATH=/bin:/usr/bin:$PATH

. ~/bin/variables.sh
export JAVA_HOME
export PATH

runIfNotThere() {
	if ! pgrep -f $1 > /dev/null; then
		echo "To run $1..."

		(
			if [ "$1" = "firefox" ]; then
				ulimit -v 1536000
			fi
			nohup $* > /dev/null
		) &
	fi
}

cd ~

# BEGIN set sound
N=$(cat /proc/asound/cards | grep V19 | cut -d' ' -f2)
echo "pcm.!default {
	type hw
	card ${N}
}
ctl.!default {
	type hw
	card ${N}
}
"> ~/.asoundrc
# END set sound

runIfNotThere chromium --force-device-scale-factor=2 --high-dpi-support=1 --incognito https://www.facebook.com/ http://finance.yahoo.com/ https://www.youtube.com/ file:///data/storey file:///home/ywsing/docs
runIfNotThere evince
runIfNotThere firefox
runIfNotThere pcmanfm ~/docs/
runIfNotThere scite "-position.left=960" "-position.top=540" "-position.width=1920" "-position.height=1080" pad ~/home-data/stock.txt ~/bin/variables.sh
runIfNotThere thunderbird
runIfNotThere tint2
runIfNotThere terminator -m
runIfNotThere xfce4-clipman
runIfNotThere yeahconsole
(export GTK2_RC_FILES=~/.tight-gtkrc-2.0 && export SWT_GTK3=0 && runIfNotThere ~/eclipse/eclipse -data ~/workspace)

#runIfNotThere /opt/idea-IC-129.451/bin/idea.sh
#runIfNotThere minitube
#(export PYTHONPATH=~/terminator/install/lib/python2.7/site-packages:/usr/share/terminator && runIfNotThere ~/terminator/install/bin/terminator -m)
#runIfNotThere tilda
#runIfNotThere wifi.sh
#runIfNotThere xcompmgr -cfF -t-9 -l-11 -r9 -o.95 -D6

sleep 2
