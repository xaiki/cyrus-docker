#!/bin/sh
set -e
set -x

export DEBIAN_FRONTEND=noninteractive
grep deb-src /etc/apt/sources.list || perl -pi -e 's/^deb (.*)$/deb $1\ndeb-src $1/g' /etc/apt/sources.list
apt update && apt install -y cyrus-imapd

test -f base-packages || dpkg -l | grep '^ii' | awk '{print $2}' > base-packages

apt build-dep cyrus-imapd -y && apt install git devscripts rsync libcunit1-dev -y
test -d cyrus-imapd-debian || git clone https://salsa.debian.org/debian/cyrus-imapd.git cyrus-imapd-debian
test -d cyrus-imapd || git clone https://github.com/cyrusimap/cyrus-imapd

(cd cyrus-imapd \
         && cp -a ../cyrus-imapd-debian/debian . \
         && v=`grep '^release' docsrc/conf.py | cut -d\' -f2 | awk '{print $1}'` \
         && dch -v $v "new upstream release" \
         && perl -pi -e 's/(--enable-xapian)/$1 --enable-jmap/' debian/rules \
         && perl -pi -e 's,contrib/sieve-spamasssassin,contrib/sieve-spamassassin,g' debian/cyrus-common.contrib \
         && echo "usr/lib/cyrus/bin/promstatsd" >> debian/cyrus-common.install \
         && env DEB_BUILD_OPTIONS=nocheck ./debian/rules binary \
         && rm -rf ../*dbgsym*.deb
)

rm -rf cyrus-imapd*

dpkg -l | grep '^ii' | awk '{print $2}' > installed-packages
apt --purge remove -y `diff base-packages installed-packages | grep '^> ' | awk '{print $2}' | xargs`

dpkg -i *.deb || apt -f install -y
rm -rf *.deb
apt clean -y
