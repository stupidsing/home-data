#!/bin/sh

PATH=/bin:/usr/bin:$PATH

. ~/bin/variables.sh
export JAVA_HOME
export PATH

runIfNotThere () {
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

cd ${HOME}

runIfNotThere /opt/google/chrome/chrome --incognito
#runIfNotThere /opt/idea-IC-129.451/bin/idea.sh
runIfNotThere icedove
runIfNotThere iceweasel
#runIfNotThere minitube
runIfNotThere pidgin
runIfNotThere tint2
runIfNotThere terminator -m
runIfNotThere yeahconsole
(export GTK2_RC_FILES=/home/ywsing/.tight-gtkrc-2.0 && export SWT_GTK3=0 && runIfNotThere /opt/eclipse/eclipse -data /home/ywsing/workspace)

#runIfNotThere tilda

sleep 2
