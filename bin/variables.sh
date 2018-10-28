export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export GRADLE_HOME=~/gradle-4.10.2
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-i386
#export JAVA_HOME=$(find /opt/ -maxdepth 1 -name jdk\* | sort | tail -1)
export M2_HOME=$(find /opt/ -maxdepth 1 -name apache-maven-\* | sort | tail -1)
export PATH=/opt/go_appengine:${GRADLE_HOME}/bin:${JAVA_HOME}/bin:${M2_HOME}/bin:${HOME}/bin:${PATH}

format() {
	python -c "if 1:
		import sys
		def nl(): sys.stdout.write('\n')
		pc, quote = '', 0
		for line in sys.stdin.readlines():
			for c in line:
				if c == chr(39): quote = 1 - quote
				if c == chr(34): quote = 2 - quote
				if quote == 0 and c in [']', '}']: nl()
				if quote != 0 or c != ' ': sys.stdout.write(c)
				if quote == 0 and c in ['[', '{', ',']: nl()
				pc = c
	" | python -c "if 1:
		import sys
		t = ''
		for line in sys.stdin.readlines():
			for c in line:
				t = t + c
				if len(t) > 3:
					h, t = t[0], t[1:]
					sys.stdout.write(h)
				if t == '{\n}': t = '{}'
		print t,
	" | python -c "if 1:
		import sys
		indent = 0
		for line in sys.stdin.readlines():
			first, last = line[:1], line.strip()[-1:]
			if first in [']', '}']: indent = indent - 1
			sys.stdout.write(indent * '  ')
			if last in ['[', '{']: indent = indent + 1
			sys.stdout.write(line)
	"
}

replace() {
	#CMD="sed 's/abc/def/g'"
	CMD="${1}"
	shift
	while [ "${1}" ]; do
		F0="${1}"
		F1=$(echo "${F0}" | "${CMD}")
		TMP="$(tempfile)"
		cat "${F0}" | sh -c "${CMD}" > "${TMP}"
		mkdir -p $(dirname "${F1}")
		mv "${TMP}" "${F1}"
		shift
	done
}

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
			while read S; do [ "${S}" ] && grep ${S}.HK ~/home-data/stock.txt; echo; echo; done
			;;
		i)
			curl -s 'http://www.aastocks.com/en/mobile/Quote.aspx?symbol=5' |
			grep -A1 HSI | tail -1 | cut -d. -f1 | python -c 'if True:
				import sys
				for line in sys.stdin.readlines():
					for c in line:
						if "0" <= c and c <= "9": sys.stdout.write(c)
				print
			'
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
					printf 'aast '; curl -s http://www.aastocks.com/en/mobile/Quote.aspx?symbol=0${S} |
					grep -A1 text_last | tail -1 | python -c 'if True:
						import sys
						for line in sys.stdin.readlines():
							for c in line.replace(".png", "").replace("0px", ""):
								if "0" <= c and c <= "9" or c == ".": sys.stdout.write(c)
						print
					'
					printf 'sina '; curl -s http://hq.sinajs.cn/?list=rt_hk0${S} | cut -d, -f7
					#printf 'yhoo '; curl -s https://download.finance.yahoo.com/d/quotes.csv?f=sl1\&s=${S}.HK
				)
				echo
				echo
			done
			;;
		s)
			(cd ~/suite/ && mvn compile exec:java -Dexec.mainClass=suite.StatusMain)
			;;
		u)
			cat ~/home-data/stock.txt | python -c "if True:
				import sys
				for line in sys.stdin.readlines():
					while 0 <= line.find('  '): line = line.replace('  ', ' ')
					print line.replace(' ', '\\t'),
			" > /tmp/stock.txt
			mv /tmp/stock.txt ~/home-data/stock.txt
			(cd ~/home-data/ && git pull && git diff && (git commit -m - stock.txt || true) && git push) &&
			(cd ~/suite/ && git pull && git status)
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
	(cd ~/suite/ && mvn compile exec:java -Dexec.mainClass=${MAINCLASS} -Dexec.args="$@")
}

PS1='[\t ($?)] '
alias pk="pkill -f"
HISTCONTROL=erasedups:ignoreboth:${HISTCONTROL}
