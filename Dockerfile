FROM debian
WORKDIR /srv
ADD build.sh /srv/build.sh
RUN sh /srv/build.sh
RUN apt update && apt install -y libsasl2-2 libsasl2-modules sasl2-bin && apt clean -y
RUN perl -pi -e 's/START=.*/START=yes/g;s/MECHANISMS=.*/MECHANISMS="sasldb"/g;' /etc/default/saslauthd
ADD entrypoint.sh /srv

ENTRYPOINT /srv/entrypoint.sh
