#export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export JAVA_HOME=$(find /opt/ -maxdepth 1 -name jdk\* | sort | tail -1)
export M2_HOME=$(find /opt/ -maxdepth 1 -name apache-maven-\* | sort | tail -1)
export PATH=/opt/go_appengine:${JAVA_HOME}/bin:${M2_HOME}/bin:${HOME}/bin:${PATH}

alias google-chrome="google-chrome --incognito"

PS1='[\t ($?)] '
export HISTCONTROL=erasedups:ignoreboth:${HISTCONTROL}
