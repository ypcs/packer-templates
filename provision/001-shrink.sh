#!/bin/sh

set -e

export DEBIAN_FRONTEND="noninteractive"

apt-get -y remove avahi-autoipd bluetooth netcat-traditional pinentry-gtk2 reportbug rpcbind telnet w3m wamerican wireless-tools wpasupplicant ftp geoip-database hicolor-icon-theme iamerican ibritish ienglish-common libavahi-* nfs-common task-english wireless-regdb

apt-get -y remove aptitude aspell aspell-en avahi-daemon dc bc debian-faq gettext-base manpages procmail info installation-report python-reportbug m4 at libclass-isa-perl texinfo bc eject doc-debian


TEMPFILE="$(mktemp)"

cat >${TEMPFILE} << EOF
localepurge	localepurge/dontbothernew	boolean	false
localepurge	localepurge/quickndirtycalc	boolean	true
localepurge	localepurge/mandelete	boolean	true
localepurge	localepurge/use-dpkg-feature	boolean	false
localepurge	localepurge/showfreedspace	boolean	true
localepurge	localepurge/verbose	boolean	false
localepurge	localepurge/remove_no	note	
localepurge	localepurge/nopurge	multiselect	en, en_US, en_US.UTF-8, fi, fi_FI.UTF-8
localepurge	localepurge/none_selected	boolean	false
EOF

debconf-set-selections < ${TEMPFILE}

apt-get -y install localepurge

localepurge

rm -f ${TEMPFILE}
