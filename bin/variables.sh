export GDK_SCALE=2
export GDK_DPI_SCALE=0.5

export ECLIPSE_HOME=/data/tmp/d1f7c3cc.http___ftp.jaist.ac.jp_pub_eclipse_technology_epp_downloads_release_2020-09_R_eclipse-java-2020-09-R-linux-gtk-x86_64.tar.gz.d/eclipse
export ECLIPSE_CPP_HOME=/data/tmp/d09be002.http___ftp.jaist.ac.jp_pub_eclipse_technology_epp_downloads_release_2020-03_R_eclipse-cpp-2020-03-R-incubation-linux-gtk-x86_64.tar.gz.d/eclipse
export GOROOT=$(find ~/ -maxdepth 1 -name goroot\* | sort | tail -1)
export GRADLE_HOME=$(find ~/ -maxdepth 1 -name gradle-\* | sort | tail -1)
export JAVA_HOME=/data/tmp/4b8e20f3.https___download.java.net_java_GA_jdk15_779bf45e88a44cbd9ea6621d33e33db1_36_GPL_openjdk-15_linux-x64_bin.tar.gz.d/jdk-15
export M2_HOME=/data/tmp/4ba3d3f0.http___ftp.cuhk.edu.hk_pub_packages_apache.org_maven_maven-3_3.6.3_binaries_apache-maven-3.6.3-bin.tar.gz.d/apache-maven-3.6.3
export NODE_HOME=/data/tmp/db28c4cb.https___nodejs.org_dist_v12.16.2_node-v12.16.2-linux-x64.tar.xz.d/node-v12.16.2-linux-x64
export PATH=${GOROOT}/bin:${GRADLE_HOME}/bin:${JAVA_HOME}/bin:${M2_HOME}/bin:${NODE_HOME}/bin:~/home-data/bin:~/bin:${PATH}

choverlay() {
	# tp_apt_i fuse_overlayfs
	L0=${PWD}
	L1=$(mktemp -d)
	UPPERDIR=$(mktemp -d)
	NAME0=$(echo "${L0}" | sed s#/#_#g)
	NAME1=$(echo "${L1}" | sed s#/#_#g)
	METAFILE0=/tmp/chbranch.${NAME0}
	METAFILE1=/tmp/chbranch.${NAME1}
	[ -f "${METAFILE0}" ] && LDS0=$(cat ${METAFILE0}) || LDS0=${L0}
	LDS1=${LDS0}:${UPPERDIR}
	echo ${LDS1} > ${METAFILE1}
	fuse-overlayfs -o lowerdir=${LDS0},upperdir=${UPPERDIR},workdir=$(mktemp -d)  ${L1}
	pushd ${L1}/
}

choverlayx() {
	L=${PWD}
	NAME=$(echo "${L}" | sed s#/#_#g)
	popd
	sudo fusermount -u ${L}
	rm /tmp/chbranch.${NAME}
}

chinese() {
	(cd ~/suite/ && java -cp $(cat target/classpath):target/suite-1.0.jar suite.text.Chinese)
}

diffFromLast() {
	while [ "${1}" ]; do
		F=${1}
		shift
		FS=/tmp/${F}.last_size
		[ -f ${FS} ] && SIZE0=$(cat ${FS}) || SIZE0=0
		SIZE1=$(stat -c %s ${F})
		[ ${SIZE0} -le ${SIZE1} ] || SIZE0=0
		dd status=none if=${F} bs=1 skip=${SIZE0} count=$((${SIZE1} - ${SIZE0}))
		printf ${SIZE1} > ${FS}
	done
}

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
				#if quote != 0 or c != ' ':
				sys.stdout.write(c)
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
			if len(line) != 1:
				first, last = line[:1], line.strip()[-1:]
				if first in [']', '}']: indent = indent - 1
				sys.stdout.write(indent * '  ')
				if last in ['[', '{']: indent = indent + 1
				sys.stdout.write(line)
	"
}

hr() {
	printf '%0*d\n\n' $(tput cols) | tr 0 ${1:-_}
}

replace() {
	#CMD="sed 's/abc/def/g'"
	CMD="${1}"
	shift
	while [ "${1}" ]; do
		F0="${1}"
		F1=$(echo "${F0}" | sh -c "${CMD}")
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
			(cd ~/home-data/ && git pull) &&
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

sc() {
	CMD="${1}"
	MD5=$(echo "${CMD}" | md5sum - | cut -d' ' -f1)
	DIR=~/.cmd-cache/${MD5:0:2}
	F=${DIR}/${MD5}.d
	if [ -f "${F}" ]; then
		sh ${CMD} | tee "${F}"
	else
		cat "${F}"
	fi
}

suite() {
	MAINCLASS=${1}
	shift
	(cd ~/suite/ && mvn compile exec:java -Dexec.mainClass=${MAINCLASS} -Dexec.args="$@")
}

PS1='[\t ($?)] '
PROMPT_COMMAND='echo -en "\e]2;${PWD/\/home\/ywsing/\~}\a"'
alias gd="git diff --no-prefix"
alias gs="git status; git stash list"
alias pk="pkill -f"
alias s="wmctrl -a"
alias tp="source <(curl -sL https://raw.githubusercontent.com/stupidsing/suite/master/src/main/sh/tools-path.sh | bash -)"
HISTCONTROL=erasedups:ignoreboth:${HISTCONTROL}
