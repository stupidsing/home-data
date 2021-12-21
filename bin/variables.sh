binary() {
	cut -d' ' -f1 | (read L
	while [ "${L}" != "" ]; do
		printf "\\x${L:0:2}"
		L="${L:2:9999}"
	done)
}

chinese() {
	(cd ~/suite/ && java -cp $(cat target/classpath):target/suite-1.0.jar suite.text.Chinese)
}

choverlay() {
	if [ "${1}" == "-l" ]; then
		# use local mounter (instead of superuser)
		local LOCAL=true
		shift
	fi

	# tp_apt_i fuse_overlayfs
	LOCAL=${LOCAL} choverlay_ ${1-$(pwd)} $(mktemp -d) $(mktemp -d)
}

choverlay_() {
	local L0=${1} UPPERDIR=${2} L1=${3}
	local NAME0=$(echo "${L0}" | sed s#/#_#g)
	local NAME1=$(echo "${L1}" | sed s#/#_#g)
	local METAFILE0=/tmp/choverlay.${NAME0}
	local METAFILE1=/tmp/choverlay.${NAME1}
	[ -f "${METAFILE0}" ] && local LDS0=$(cat ${METAFILE0}) || local LDS0=${L0}
	local LDS1=${LDS0}:${UPPERDIR}
	echo ${LDS1} > ${METAFILE1}
	if [ "${LOCAL}" ]; then
		fuse-overlayfs -o lowerdir=${LDS0},upperdir=${UPPERDIR},workdir=${WORKDIR-$(mktemp -d)} ${L1}
	else
		sudo mount -t overlay stack_${NAME1} -o lowerdir=${LDS0},upperdir=${UPPERDIR},workdir=${WORKDIR-$(mktemp -d)} ${L1}
	fi
	pushd ${L1}/ > /dev/null
}

choverlayx() {
	if [ "${1}" == "-l" ]; then
		local LOCAL=true
		shift
	fi

	local L=${PWD}
	local NAME=$(echo "${L}" | sed s#/#_#g)
	popd > /dev/null
	if [ "${LOCAL}" ]; then
		sudo fusermount -u ${L}
	else
		sudo umount ${L}
	fi
	rm /tmp/choverlay.${NAME}
}

diff-from-last() {
	while [ "${1}" ]; do
		local F=${1}
		shift
		local FS=/tmp/${F}.last_size
		[ -f ${FS} ] && SIZE0=$(cat ${FS}) || SIZE0=0
		local SIZE1=$(stat -c %s ${F})
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
		sys.stdout.write(t)
	" | python -c "if 1:
		import sys
		indent = 0
		for line in sys.stdin.readlines():
			if line.strip():
				first, last = line[:1], line.strip()[-1:]
				if first in [']', '}']: indent = indent - 1
				sys.stdout.write(indent * '  ')
				if last in ['[', '{']: indent = indent + 1
				sys.stdout.write(line)
	"
}

fsel() {
	D=${1-src}
	PS3="Select a file: "
	select F in $(find ${D}/ -type f)
	do
		printf ${F} | xsel -b
		return 0
	done
}

hr() {
	printf '%0*d\n\n' $(tput cols) | tr 0 ${1:-_}
}

# replace "cat | sed 's/abc/def/g'" $(find -name \*.js -type f)
replace() {
	#local CMD="cat | sed 's/abc/def/g'"
	local CMD="${1}"
	shift
	while [ "${1}" ]; do
		local F0="${1}"
		local F1=$(echo "${F0}" | sh -c "${CMD}")
		local TMP="$(tempfile)"
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
		local H=${1:0:1}
		local T=${1:1}
		case "${H}" in
		h)
			while read S; do [ "${S}" ] && grep ${S}.HK ~/home-data/stock.txt; echo; echo; done
			;;
		i)
			curl -sL https://www.sl886.com/adr | grep -A1 '<h3>恆生指數</h3>' | sed 's/.*label-danger">\(.*\)&nbsp;&nbsp;.*/\1/g' | tail -1
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

suite() {
	local MAINCLASS=${1}
	shift
	(cd ~/suite/ && mvn compile exec:java -Dexec.mainClass=${MAINCLASS} -Dexec.args="$@")
}

HISTCONTROL=erasedups:ignoreboth:ignoredups:${HISTCONTROL}
PS1='[\t ($?)] '
PROMPT_COMMAND='echo -en "\e]2;${PWD/\/home\/ywsing/\~}\a"'
alias gd="git diff -b --no-prefix"
alias gs="git status; git stash list"
alias pk="pkill -f"
alias s="wmctrl -a"
alias tp="source <(curl -sL https://raw.githubusercontent.com/stupidsing/suite/master/src/main/sh/tools-path.sh | bash -)"
