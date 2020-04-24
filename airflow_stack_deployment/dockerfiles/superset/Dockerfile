FROM amancevice/superset:0.35.2
MAINTAINER ixime

USER root

ARG NEWUID=1010
ARG NEWGID=1090

RUN OLDUID=$(id -u superset) && \
    OLDGID=$(id -g superset) && \
    usermod -u ${NEWUID} superset && \
    groupmod -g ${NEWGID} superset && \
    find / -xdev -group $OLDGID -exec chgrp -h superset {} \; && \
    find / -xdev -user $OLDUID -exec chown -h superset {} \;

USER superset
