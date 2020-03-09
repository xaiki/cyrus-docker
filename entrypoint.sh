#!/bin/sh

service saslauthd restart

if grep '^conversations:' /etc/imapd.conf; then
        perl -pi -e 's/^(conversations:) .*/$1 1/g' /etc/imapd.conf;
else
        echo "conversations: 1" >> /etc/imapd.conf
fi
if grep '^conversations_db:' /etc/imapd.conf; then
        perl -pi -e 's/^(conversations_db:) .*/$1 twoskip/g' /etc/imapd.conf;
else
        echo "conversations_db: twoskip" >> /etc/imapd.conf
fi
if grep '^httpmodules:' /etc/imapd.conf; then
        if grep '^httpmodules:' /etc/imapd.conf | grep 'jmap'; then
                echo "JMAP already enabled"
        else
                perl -pi -e 's/^(httpmodules:) (.*)/$1 $2 jmap/g' /etc/imapd.conf;
        fi
else
        echo "httpmodules: jmap" >> /etc/imapd.conf
fi

perl -pi 's/^(\s+)(pop3.*)/$1#$2/g/' /etc/cyrus.conf # disable pop
perl -pi 's/^(\s+)#(\s+imap.*)/$1$2/g/' /etc/cyrus.conf # enable imap
perl -pi 's/^(\s+)#(\s+squatter.*)/$1$2/g/' /etc/cyrus.conf # enable inbox indexing

perl -pi 's/^(\s+)#?(\s+admins:)(.*)$/$1$2 cyrus/g' /etc/imapd.conf
perl -pi 's/^(\s+)#?(\s+sasl_mech_list:)(.*)$/$1$2 DIGEST-MD5 CRAM-MD5 PLAIN LOGIN/g' /etc/imapd.conf
perl -pi 's/^(\s+)#?(\s+sasl_pwcheck_method:)(.*)$/$1$2 saslauthd/g' /etc/imapd.conf

