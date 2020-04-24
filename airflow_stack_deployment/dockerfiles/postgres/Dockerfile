FROM postgres:9.6
MAINTAINER ixime

USER root

ARG NEWUID=1010
ARG NEWGID=1090

RUN OLDUID=$(id -u postgres) && \
    OLDGID=$(id -g postgres) && \
    usermod -u ${NEWUID} postgres && \
    groupmod -g ${NEWGID} postgres && \
    find / -xdev -group $OLDGID -exec chgrp -h postgres {} \; && \
    find / -xdev -user $OLDUID -exec chown -h postgres {} \;

RUN chown -R postgres:postgres /var/lib/postgresql/data
