#!/bin/sh

OLDPARTITION=/dev/sda7

mount "${OLDPARTITION}" /mnt

################################################################################
# System-wide setup
if ! grep data /etc/fstab > /dev/null; then
  mkdir /data
  echo "/dev/sda1    /data    ext4    defaults    0    0" >> /etc/fstab
  mount -a
fi

if ! grep datausers /etc/group > /dev/null; then
  echo "datausers:x:1001:ywsing" >> /etc/group
fi

if ! grep skyee /etc/hosts > /dev/null; then
echo "
192.168.1.7  parents
192.168.1.8  eva
192.168.1.10 skyee
192.168.1.11 smartq
192.168.1.12 n9
" >> /etc/hosts
fi

echo "# You may comment out this entry, but any other modifications may be lost.
deb http://dl.google.com/linux/chrome/deb/ stable main
" > /etc/apt/sources.list.d/google-chrome.list

usermod -a -G fuse ywsing
echo user_allow_other >> /etc/fuse.conf
chmod 755 /root

restore() {
  DIR=`dirname "${1}"`
  sudo -u ywsing mkdir -p "${DIR}"
  cp -a -r "/mnt${1}" "${DIR}"
}

restore /opt/madedit

FONTDIR=/usr/share/fonts/X11/misc
for FONT in 6x13 6x13B; do
  restore ${FONTDIR}/ywsing-${FONT}.pcf.gz
done

mkfontdir ${FONTDIR} && su ywsing -c "xset fp rehash"

# disables font emboldening
sed -i s/true/false/g /etc/fonts/conf.d/90-synthetic.conf

# uses CUHK mirror
#sed -i s/hk.archive.ubuntu.com/ftp.cuhk.edu.hk\\/pub\\/Linux/g /etc/apt/sources.list

# disables swap
echo "swapoff -a" >> /etc/init.d/rc.local

# disables crash reporter
#sed -i s/enabled=1/enabled=0/ /etc/default/apport

# optimizations for SSD drive
# http://superuser.com/questions/228657/which-linux-filesystem-works-best-with-ssd

# disables PC speaker
(
  echo blacklist pcspkr
  echo blacklist snd_pcsp
) >> /etc/modprobe.d/blacklist.conf
rmmod pcspkr
rmmod snd_pcsp

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
restoreHome .fonts.conf
restoreHome .fonts/Akkurat
restoreHome .fonts/Bitstream
restoreHome .fonts/chinese
restoreHome .fonts/Droid
restoreHome ".fonts/HP Fonts"
restoreHome .fonts/Merienda
restoreHome .fonts/monos
restoreHome .fonts/Nokia
restoreHome ".fonts/Nokia Pure"
restoreHome .fonts/ParaType
restoreHome .fonts/sans
restoreHome .fonts/serifs
restoreHome ".fonts/Vernon Adams"
restoreHome .fonts/xfonts
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
restoreHome .Xresources
restoreHome bin
restoreHome desktop

USERSCRIPT=/tmp/user.run

cat > ${USERSCRIPT} << IN
gsettings set org.gnome.desktop.background picture-uri 'file:///data/ubuntu/wallpapers/wood.png'
gsettings set org.gnome.desktop.interface document-font-name 'Sans 10.8'
gsettings set org.gnome.desktop.interface font-name 'Sans 10.8'
gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 10.8'
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false

gsettings set org.gnome.gedit.preferences.editor auto-indent true
gsettings set org.gnome.gedit.preferences.editor create-backup-copy false
gsettings set org.gnome.gedit.preferences.editor editor-font 'Monospace 9'
gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
gsettings set org.gnome.gedit.preferences.editor tabs-size 4
gsettings set org.gnome.gedit.preferences.editor use-default-font false

gsettings set org.gnome.nautilus.desktop font 'Ubuntu 11'

gsettings set org.gnome.settings-daemon.peripherals.keyboard delay 250
gsettings set org.gnome.settings-daemon.peripherals.keyboard repeat-interval 32

gconftool -s /apps/gedit-2/preferences/ui/toolbar/toolbar_visible -t bool false

gconftool -s /apps/gnome-screensaver/lock_enabled -t bool false

#gconftool -s /apps/gnome-terminal/profiles/Default/allow_bold -t bool false
gconftool -s /apps/gnome-terminal/profiles/Default/background_color -t string "#000000000000"
gconftool -s /apps/gnome-terminal/profiles/Default/background_darkness -t float 0.8
gconftool -s /apps/gnome-terminal/profiles/Default/background_type -t string transparent
gconftool -s /apps/gnome-terminal/profiles/Default/default_show_menubar -t bool false
gconftool -s /apps/gnome-terminal/profiles/Default/font -t string Monospace\ 10
gconftool -s /apps/gnome-terminal/profiles/Default/foreground_color -t string "#AAAAAAAAAAAA"
gconftool -s /apps/gnome-terminal/profiles/Default/palette -t string "#2E2E34343636:#CCCC00000000:#4E4E9A9A0606:#C4C4A0A00000:#34346565A4A4:#757550507B7B:#060698209A9A:#D3D3D7D7CFCF:#555557575353:#EFEF29292929:#8A8AE2E23434:#FCFCE9E94F4F:#72729F9FCFCF:#ADAD7F7FA8A8:#3434E2E2E2E2:#EEEEEEEEECEC"
gconftool -s /apps/gnome-terminal/profiles/Default/scrollbar_position -t string hidden
gconftool -s /apps/gnome-terminal/profiles/Default/silent_bell -t bool true
gconftool -s /apps/gnome-terminal/profiles/Default/use_system_font -t bool false
gconftool -s /apps/gnome-terminal/profiles/Default/use_theme_colors -t bool false

gconftool -s /apps/metacity/general/titlebar_font -t string "Sans Bold 10.8"
gconftool -s /apps/metacity/global_keybindings/run_command_terminal -t string "<Control><Alt>t"

gconftool -s /apps/nautilus/list_view/default_visible_columns -t list --list-type=string "[name,size,date_modified]"
gconftool -s /apps/nautilus/preferences/date_format -t string iso
gconftool -s /apps/nautilus/preferences/default_folder_viewer -t string list_view
gconftool -s /apps/nautilus/preferences/desktop_font -t string "Sans 10.8"

#gconftool -s /apps/panel/applets/clock_screen0/format -t string 24-hour
#gconftool --recursive-unset /apps/panel/default_setup/applets/mixer
gconftool -s /apps/panel/general/show_program_list -t bool true

gconftool -s /desktop/gnome/background/picture_filename -t string "/data/ubuntu/wallpapers/wood.png"
gconftool -s /desktop/gnome/background/picture_options -t string "zoom"
gconftool -s /desktop/gnome/font_rendering/antialiasing -t string rgba
gconftool -s /desktop/gnome/font_rendering/dpi -t float 96
gconftool -s /desktop/gnome/font_rendering/hinting -t string slight
gconftool -s /desktop/gnome/font_rendering/rgba_order -t string rgb
gconftool -s /desktop/gnome/interface/font_name -t string "Sans 10.8"
#gconftool -s /desktop/gnome/peripherals/mouse/left_handed -t bool true
#gconftool -s /desktop/gnome/sound/mouse/event_sounds -t bool false

gconftool -s /desktop/gnome/applications/terminal/exec -t string terminator
gconftool -s /desktop/gnome/applications/terminal/exec_arg -t string "\-x"
gconftool -s /desktop/gnome/applications/window_manager/default -t string "/usr/bin/compiz"
gconftool -s /desktop/gnome/applications/window_manager/current -t string "/usr/bin/compiz"

# Replaced by gsettings in GNOME 3
# gconftool -s /apps/gedit-2/preferences/editor/auto_indent/auto_indent -t bool true
# gconftool -s /apps/gedit-2/preferences/editor/line_numbers/display_line_numbers -t bool true
# gconftool -s /apps/gedit-2/preferences/editor/save/create_backup_copy -t bool false
gconftool -s /desktop/gnome/peripherals/keyboard/delay -t int 250
gconftool -s /desktop/gnome/peripherals/keyboard/rate -t int 32

xrdb -load ${HOME}/.Xresources
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

apt update && (
  apt -y --force-yes --no-install-recommends install \
    abiword \
    asunder \
    bochs \
    catdoc \
    chromium \
    cifs-utils \
    deborphan \
    dosbox \
    fontforge \
    g++ \
    gcin \
    gconf-editor \
    git-core \
    gnome-tweak-tool \
    gnugo \
    gnumeric \
    gparted \
    gpicview \
    graphviz \
    imagemagick \
    leafpad \
    libreadline-dev \
    mpg321 \
    openbox \
    openjdk-11-jdk \
    pcmanfm \
    pidgin \
    pidgin-hotkeys \
    rlwrap \
    rsync \
    rxvt-unicode \
    scite \
    ssh \
    sshfs \
    subversion \
    supertux \
    terminator \
    thunderbird \
    tint2 \
    torcs \
    ttf-wqy-zenhei \
    vim \
    virtualbox \
    w3m \
    wine \
    wmctrl \
    xchm \
    xclip \
    xinput \
    xscavenger \
    yeahconsole \
    zip \
  ||
  exit 1
) &&
apt-get -y dist-upgrade &&
apt-get clean

# flashplugin-nonfree totem-gstreamer
# wesnoth
# rar unrar # No installation candidate?
# google-chrome-beta # Need to add google repo
# fglrx-updates # open source driver is enough?
# lame # ripping mp3s
# kompozer # no installation candidates

# disables global hidden menu bar
apt-get -y remove --purge \
  unity-gtk2-module unity-gtk3-module appmenu-qt

apt-get -y remove --purge \
  evolution-data-server scim \
  fonts-liberation ttf-arphic-uming ttf-liberation ttf-unfonts-core ttf-wqy-microhei ttf-mscorefonts-installer
apt-get -y remove --purge `deborphan`
apt-get -y remove --purge `deborphan`
apt-get -y remove --purge `deborphan`
apt-get -y autoremove --purge

# replaces ssh host keys
service ssh stop
cp /mnt/etc/ssh/* /etc/ssh # uses the old keys
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
  cd /opt && tar zxf /tmp/puzzles.tar.gz &&
  cd /opt/puzzles* && apt-get build-dep -y sgt-puzzles && ./configure && make
)

################################################################################
# User setup after package installation
su ywsing -c "im-switch -s gcin"
su ywsing -c "gsettings set com.canonical.Unity.Panel systray-whitelist \"['JavaEmbeddedFrame', 'Mumble', 'Wine', 'Skype', 'hp-systray', 'scp-dbus-service', 'gcin']\""

su ywsing -c "
  git clone git://github.com/stupidsing/suite.git &&
  #mvn -Declipse.workspace=. eclipse:add-maven-repo
  #cd suite && mvn -Dmaven.test.skip=true eclipse:eclipse install assembly:single
"

# cat /proc/asound/cards # find sound card number

su ywsing -c "echo 'pcm.!default {
	type hw
	card 2
}

ctl.!default {
	type hw
	card 2
}
' > /home/ywsing/.asoundrc"

#echo "gtk-menu-popup-delay = 0" > /home/ywsing/.gtkrc-2.0

echo Please restart.

#echo 'GTK_IM_MODULE=scim-bridge' >> /etc/X11/xinit/xinput.d/scim
#echo 'QT_IM_MODULE=scim' >> /etc/X11/xinit/xinput.d/scim

# System Settings -> User Accounts -> ywsing -> Unlock -> Automatic Login

# gnome-session-properties # add following command
# /usr/bin/xterm -e "echo 'Press Ctrl-C to interrupt startup sequence' && /bin/sleep 2 && /home/ywsing/bin/set-home.sh"

# firefox
# # Edit -> Preferences
# # General -> Desktop Integration -> Prompt integration options for any website -> untick
# # General -> When Firefox starts: -> Show a blank page
# # Tabs -> Open new window in a new tab instead -> untick
# # Tabs -> Always show the tab bar -> untick

# ccsm
# # clicks into Ubuntu Unity Plugin, change
# # Key to show the HUD / Key to show the launcher
# # and disables it
# # your favorites: enable Color Filter, Put, Ring Switcher, Static Application Switcher

# gnome-control-center # sets audio device

# download and decompress eclipse
DO="
(cd /tmp &&
  wget http://jd.benow.ca/jd-eclipse/downloads/jdeclipse_update_site.zip
) &&
(cd /opt/eclipse/ &&
  unzip /tmp/jdeclipse_update_site.zip plugins/jd.ide.eclipse.linux.x86_64_0.1.5.jar plugins/jd.ide.eclipse_0.1.5.jar
)
"
# # Window -> Preferences ->
# # General -> Editor -> File Associations ->
# # *.class without sources -> Associated editors: ->
# # Add... -> Class File Editor ->
# # Default
#
# install jd-eclipse [mchr3k] from http://mchr3k-eclipse.appspot.com/
