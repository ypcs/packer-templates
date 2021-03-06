#!/bin/sh

set -e

export DEBIAN_FRONTEND="noninteractive"

apt-get -y autoremove avahi-autoipd bluetooth netcat-traditional pinentry-gtk2 reportbug telnet w3m wamerican wireless-tools wpasupplicant ftp geoip-database hicolor-icon-theme iamerican ibritish ienglish-common libavahi-* task-english wireless-regdb aptitude aspell aspell-en avahi-daemon dc bc debian-faq gettext-base manpages procmail info installation-report python-reportbug m4 at libclass-isa-perl texinfo bc eject doc-debian python-pil python-pygments ispell mlocate rename libpcsclite1 util-linux-locales libgpm2 tcpd acpi acpi-support-base apt-listchanges apt-utils aptitude-common aptitude-doc-en bsd-mailx deborphan dictionaries-common discover docutils-doc exim4 iw krb5-locales libarchive-extract-perl libasprintf0c2 libauthen-sasl-perl libboost-iostreams1.55.0 libcgi-fast-perl libclass-c3-xs-perl libcwidget3 libfreetype6 libfuse2 libgpm2 libhtml-form-perl libhtml-format-perl libhttp-daemon-perl libintl-perl liblcms2-2 libmailtools-perl libmodule-build-perl libmodule-pluggable-perl libmodule-signature-perl libpackage-constants-perl libpaper-utils libparse-debianchangelog-perl libpod-latex-perl libpod-readme-perl libsasl2-modules libsigsegv2 libsoftware-license-perl libswitch-perl libterm-ui-perl libtext-soundex-perl libtext-unidecode-perl libtiff5 libwebpdemux1 libwebpmux1 libxapian22 libxml-libxml-perl libxml-sax-expat-perl localepurge logrotate lsb-release lsof man-db mutt ncdu ncurses-term net-tools nfacct powertop psmisc python-debian python-debianbts rsyslog tcpd time traceroute util-linux-locales vim-tiny whiptail whois xauth

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
