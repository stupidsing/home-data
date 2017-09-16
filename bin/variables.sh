export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-i386
#export JAVA_HOME=$(find /opt/ -maxdepth 1 -name jdk\* | sort | tail -1)
export M2_HOME=$(find /opt/ -maxdepth 1 -name apache-maven-\* | sort | tail -1)
export PATH=/opt/go_appengine:${JAVA_HOME}/bin:${M2_HOME}/bin:${HOME}/bin:${PATH}
export PATH=$(find /opt/ -maxdepth 1 -name gradle-\* | sort | tail -1)/bin:${PATH}

rsync2() {
	rsync -avz "${2}" "${1}"
	rsync -avz "${1}" "${2}"
}

stock() {
	if [ "${1}" ]; then
		H=${1:0:1}
		T=${1:1}
		case "${H}" in
		h)
			while read S; do [ "${S}" ] && grep ${S}.HK ~/workspace/home-data/stock.txt; echo; echo; done
			;;
		o)
			cat /tmp/orders |
			egrep -A3 'Pending' |
			egrep -v '^--|^Delete|^Modify|^Please' |
			python -c "if True:
				import sys
				f, line0 = 0, ''
				for line in sys.stdin:
					if f: print line0.replace('Details', '').strip(), line.strip()
					f, line0 = 1 - f, line
			" |
			sort |
			tee /tmp/orders
		;;
		q)
		while read S; do
			[ "${S}" ] && (
				printf 'sina '; curl -s http://hq.sinajs.cn/?list=rt_hk0${S} | cut -d, -f7
				printf 'yhoo '; curl -s https://download.finance.yahoo.com/d/quotes.csv?f=sl1\&s=${S}.HK
			)
			echo
			echo
		done
		;;
		s)
			(cd ~/workspace/suite/ && mvn compile exec:java -Dexec.mainClass=suite.StatusMain)
			;;
		u)
			(cd ~/workspace/home-data/ && git pull && git diff && (git commit -m - stock.txt || true) && git push) &&
			(cd ~/workspace/suite/ && git pull && git status)
			;;
		y)
			rsync2 ~/docs/ stupidsing.no-ip.org:public_html/docs/
			rsync2 ~/.fonts/ stupidsing.no-ip.org:public_html/fonts/
			#rsync -avz ~/yahoo/ stupidsing.no-ip.org:yahoo/
			;;
		esac &&
		stock "${T}"
	fi
}

suite() {
	MAINCLASS=${1}
	shift
	(cd ~/workspace/suite/ && mvn compile exec:java -Dexec.mainClass=${MAINCLASS} -Dexec.args="$@")
}

PS1='[\t ($?)] '
export HISTCONTROL=erasedups:ignoreboth:${HISTCONTROL}
