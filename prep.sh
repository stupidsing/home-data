#!/bin/sh

mkdir -p ${HOME}/bin

printf "pcm.!default {
	type hw
	card 2
}

ctl.!default {
	type hw
	card 2
}
" > ${HOME}/.asoundrc

printf ". ${HOME}/bin/variables.sh
" > ${HOME}/.bashrc

printf "font.base=font:Droid Sans,size:10
font.small=font:Droid Sans,size:8
font.comment=font:Droid Serif,size:10
font.monospace=font:Droid Sans Mono,size:10
font.vbs=font:Droid Sans Mono,size:10
load.on.activate=1
" > ${HOME}/.SciTEUser.properties

printf "set ai
set encoding=utf-8
set incsearch
set noswapfile
set sw=4
set ts=4
set viminfo=
syn on
" > ${HOME}/.vimrc

printf "URxvt.background:		[95]#000000
URxvt.font:			7x14bold
URxvt.foreground:		[95]#AAAAAA
URxvt.scrollBar:		false
yeahconsole*aniDelay:		40
yeahconsole*consoleHeight:	40
yeahconsole*restart:		1
yeahconsole*screenWidth:	840
yeahconsole*stepSize:		0
yeahconsole*term:		urxvt
yeahconsole*toggleKey:		+F1
yeahconsole*xOffset:		420
" > ${HOME}/.Xresources

printf "xset r rate 200 56
xinput --set-prop 'USB OPTICAL MOUSE ' 'libinput Accel Speed' 1
" > ${HOME}/.xsessionrc
