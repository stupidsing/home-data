#!/bin/bash

PATH=/bin:/usr/bin:${PATH}

. ~/bin/variables.sh
export JAVA_HOME
export PATH

runIfNotThere() {
	if ! pgrep -f $1 > /dev/null; then
		echo "To run $1..."

		(
			nohup $* > /dev/null
		) &
	fi
}

cd ~

runIfNotThere chromium --force-device-scale-factor=2 --high-dpi-support=1 --incognito http://finance.yahoo.com/ https://www.youtube.com/ file:///data/storey file:///home/ywsing/docs
runIfNotThere evince
runIfNotThere firefox
runIfNotThere lxpanel
runIfNotThere pcmanfm ~/docs/
runIfNotThere scite pad ~/home-data/stock.txt ~/bin/variables.sh
runIfNotThere thunderbird
runIfNotThere /usr/bin/x-terminal-emulator -m
runIfNotThere xfce4-clipman
runIfNotThere yeahconsole
runIfNotThere ${ECLIPSE_HOME}/eclipse -data ~/workspace

#runIfNotThere /opt/idea-IC-129.451/bin/idea.sh
#runIfNotThere minitube
#(export PYTHONPATH=~/terminator/install/lib/python2.7/site-packages:/usr/share/terminator && runIfNotThere ~/terminator/install/bin/terminator -m)
#runIfNotThere tilda
#runIfNotThere tint2
#runIfNotThere wifi.sh
#runIfNotThere xcompmgr -cfF -t-9 -l-11 -r9 -o.95 -D6
#(GTK2_RC_FILES=~/.tight-gtkrc-2.0 GTK_IM_MODULE= SWT_GTK3=0 runIfNotThere ${ECLIPSE_CPP_HOME}/eclipse -data ~/workspace.cpp)

sleep 2
