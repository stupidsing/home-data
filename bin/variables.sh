export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-i386
#export JAVA_HOME=$(find /opt/ -maxdepth 1 -name jdk\* | sort | tail -1)
export M2_HOME=$(find /opt/ -maxdepth 1 -name apache-maven-\* | sort | tail -1)
export PATH=/opt/go_appengine:${JAVA_HOME}/bin:${M2_HOME}/bin:${HOME}/bin:${PATH}
export PATH=$(find /opt/ -maxdepth 1 -name gradle-\* | sort | tail -1)/bin:${PATH}

alias chromium="chromium --incognito"

PS1='[\t ($?)] '
export HISTCONTROL=erasedups:ignoreboth:${HISTCONTROL}
