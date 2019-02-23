#!/bin/sh

################################################################################
# Mounts

OLDPART=sdb1
OLDPARTITION=/dev/${OLDPART}

mkdir -p /${OLDPART}
mount "${OLDPARTITION}" /${OLDPART}

################################################################################
# System-wide setup
grep data /etc/fstab > /dev/null || (
  mkdir /data
  echo "tmpfs /tmp tmpfs defaults 0 0" >> /etc/fstab
  echo "/dev/sda1 /data ext4 defaults 0 0" >> /etc/fstab
  echo "${OLDPARTITION} /${OLDPART} ext4 defaults 0 0" >> /etc/fstab
  mount -a
)

grep datausers /etc/group > /dev/null || (
  echo "datausers:x:1001:ywsing" >> /etc/group
)

usermod -a -G fuse ywsing
echo user_allow_other >> /etc/fuse.conf
chmod 755 /root

restore() {
  DIR=`dirname "${1}"`
  sudo -u ywsing mkdir -p "${DIR}"
  cp -a -r "/${OLDPART}${1}" "${DIR}"
}

restore /opt/madedit

FONTDIR=/usr/share/fonts/X11/misc
for FONT in 6x13 6x13B; do
  restore ${FONTDIR}/ywsing-${FONT}.pcf.gz
done

mkfontdir ${FONTDIR} && su ywsing -c "xset fp rehash"

# disables font emboldening
sed -i s/true/false/g /etc/fonts/conf.d/90-synthetic.conf

# disables swap
echo "swapoff -a" >> /etc/init.d/rc.local

# disables PC speaker
(
  echo blacklist pcspkr
  echo blacklist snd_pcsp
) >> /etc/modprobe.d/blacklist.conf
rmmod pcspkr
rmmod snd_pcsp

# auto-login
sed "s/#autologin-user=/autologin-user=ywsing/g"  -i /etc/lightdm/lightdm.conf

################################################################################
# User profile setup
restoreHome() {
  restore "/home/ywsing/${1}"
}

rmdir /home/ywsing/*

restoreHome .asoundrc
restoreHome .config/user-dirs.dirs
restoreHome .config/terminator
restoreHome .config/tint2
restoreHome .dosbox
restoreHome .tight-gtkrc-2.0
restoreHome .fonts/
restoreHome .fonts.conf
restoreHome .gcin
restoreHome .inputrc
restoreHome .koules-levels
restoreHome .madedit
restoreHome .purple
restoreHome .ssh
restoreHome .supertux2
restoreHome .tilda
restoreHome .torcs
restoreHome .thunderbird
restoreHome .vim
restoreHome .viminfo
restoreHome .vimrc
restoreHome .VirtualBox
restoreHome bin
restoreHome desktop

USERSCRIPT=/tmp/user.run

cat > ${USERSCRIPT} << IN
gsettings get org.gnome.desktop.background picture-uri 'file:///data/ubuntu/wallpapers/wood.png'
gsettings set org.gnome.desktop.interface document-font-name 'Sans 10'
gsettings set org.gnome.desktop.interface font-name 'Sans 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 10'
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
gsettings set org.gnome.nautilus.desktop font 'Ubuntu 11'

gsettings set org.gnome.settings-daemon.peripherals.keyboard delay 250
gsettings set org.gnome.settings-daemon.peripherals.keyboard repeat-interval 32

gconftool -s /apps/gnome-screensaver/lock_enabled -t bool false

gconftool -s /desktop/gnome/background/picture_filename -t string "/data/ubuntu/wallpapers/wood.png"
gconftool -s /desktop/gnome/background/picture_options -t string "zoom"
gconftool -s /desktop/gnome/font_rendering/antialiasing -t string rgba
gconftool -s /desktop/gnome/font_rendering/dpi -t float 96
gconftool -s /desktop/gnome/font_rendering/hinting -t string slight
gconftool -s /desktop/gnome/font_rendering/rgba_order -t string rgb
gconftool -s /desktop/gnome/interface/font_name -t string "Sans 10.8"
#gconftool -s /desktop/gnome/peripherals/mouse/left_handed -t bool true
#gconftool -s /desktop/gnome/sound/mouse/event_sounds -t bool false

xrdb -load \${HOME}/.Xresources
IN

chown ywsing.ywsing ${USERSCRIPT}
chmod 755 ${USERSCRIPT}
su ywsing -c "sh -c ${USERSCRIPT}"
rm ${USERSCRIPT}

su ywsing -c "(echo && echo 'source ${HOME}/bin/variables.sh') >> ${HOME}/.bashrc"

################################################################################
# System package setup

# Do not install recommends and suggests
cat > /etc/apt/apt.conf.d/01norecommend << EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF

# Adds ppa repository for newer packages
#add-apt-repository ppa:ubuntu-mozilla-daily/ppa

sed "s# stretch # sid #g" -i /etc/apt/sources.list

apt update &&
apt-get -y dist-upgrade && (
  apt -y --force-yes --no-install-recommends install \
    abiword asunder \
    bochs build-essential \
    catdoc chromium cifs-utils \
    deborphan dosbox \
    fontforge \
    g++ gcin gconf-editor gdb git-core gnome-tweak-tool gnugo gnumeric gparted gpicview graphviz \
    imagemagick \
    leafpad libreadline-dev \
    mpg321 \
    obconf openbox openjdk-11-jdk \
    pavucontrol pcmanfm \
    rlwrap rsync rxvt-unicode \
    scite ssh sshfs subversion supertux \
    terminator thunderbird \
    tint2 torcs ttf-wqy-zenhei \
    vim virtualbox \
    w3m wine wmctrl \
    xchm xclip xinput xscavenger \
    yeahconsole \
    zip \
  ||
  exit 1
) &&
apt-get clean

# flashplugin-nonfree totem-gstreamer
# wesnoth
# rar unrar # No installation candidate?
# google-chrome-beta # Need to add google repo
# fglrx-updates # open source driver is enough?
# lame # ripping mp3s
# kompozer # no installation candidates

# disables global hidden menu bar
apt-get -y remove --purge unity-gtk2-module unity-gtk3-module appmenu-qt

apt-get -y remove --purge \
  evolution-data-server \
  fonts-liberation \
  scim \
  ttf-arphic-uming ttf-liberation ttf-mscorefonts-installer ttf-unfonts-core ttf-wqy-microhei
apt-get -y remove --purge `deborphan`
apt-get -y remove --purge `deborphan`
apt-get -y remove --purge `deborphan`
apt-get -y autoremove --purge

# replaces ssh host keys
service ssh stop
cp /${OLDPART}/etc/ssh/* /etc/ssh # uses the old keys
service ssh start

# change the wqy font configuration to allow local .fonts.conf in user directory
WQYFONTCONFIG=/etc/fonts/conf.avail/44-wqy-zenhei.conf
[ -f ${WQYFONTCONFIG} ] && (
    sed -i 's/<alias>/<!--alias>/g' ${WQYFONTCONFIG}
    sed -i 's/<\/alias>/<\/alias-->/g' ${WQYFONTCONFIG}
)

# disables sleep button
# sed -i s/^event=/#event=/ /etc/acpi/events/sleepbtn
# sed -i s/^action=/#action=/ /etc/acpi/events/sleepbtn

# disables suspend/hibernate
# sed -i 's/<allow_active>yes/<allow_active>no/g' /usr/share/polkit-1/actions/org.freedesktop.upower.policy

# builds newest Simon Tatham's Puzzle Collection
(
  cd /tmp && wget http://www.chiark.greenend.org.uk/~sgtatham/puzzles/puzzles.tar.gz &&
  cd ~ && tar zxf /tmp/puzzles.tar.gz &&
  cd ~/puzzles* && apt-get build-dep -y sgt-puzzles && ./configure && make
)

################################################################################
# User setup after package installation
su ywsing -c "im-switch -s gcin"

su ywsing -c "
  git clone git://github.com/stupidsing/suite.git &&
  #mvn -Declipse.workspace=. eclipse:add-maven-repo &&
  #cd suite/ && mvn -Dmaven.test.skip=true eclipse:eclipse install assembly:single &&
  true
"

#echo "gtk-menu-popup-delay = 0" > /home/ywsing/.gtkrc-2.0

echo Please restart.

# System Settings -> User Accounts -> ywsing -> Unlock -> Automatic Login

# firefox
# # Edit -> Preferences
# # General -> Desktop Integration -> Prompt integration options for any website -> untick
# # General -> When Firefox starts: -> Show a blank page
# # Tabs -> Open new window in a new tab instead -> untick

# https://ecd-plugin.github.io/ecd/
~/eclipse/eclipse -application org.eclipse.equinox.p2.director -repository https://ecd-plugin.github.io/update -installIU org.sf.feeling.decompiler.feature.group
~/eclipse/eclipse -application org.eclipse.equinox.p2.director -repository https://ecd-plugin.github.io/update -installIU org.sf.feeling.decompiler.cfr
#~/eclipse/eclipse -application org.eclipse.equinox.p2.director -repository https://ecd-plugin.github.io/update -installIU org.sf.feeling.decompiler.jad
#~/eclipse/eclipse -application org.eclipse.equinox.p2.director -repository https://ecd-plugin.github.io/update -installIU org.sf.feeling.decompiler.jd
#~/eclipse/eclipse -application org.eclipse.equinox.p2.director -repository https://ecd-plugin.github.io/update -installIU org.sf.feeling.decompiler.procyon

# Window -> Preferences -> General -> Editors -> File Associations
# -> "*.class" -> "Class Decompiler Viewer" is selected by default.
# -> "*.class without source" -> "Class Decompiler Viewer" is selected by default.
# Window -> Preferences -> Java -> Decompiler -> Default -> CFR (xxx)

# Thunderbird
# -> Edit -> Preferences
# -> Advanced
# -> General
# -> Config Editor
# -> mailnews.remember_selected_message
# -> set to false
