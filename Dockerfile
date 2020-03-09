FROM debian
WORKDIR /srv
ADD build.sh /srv/build.sh
RUN sh /srv/build.sh
