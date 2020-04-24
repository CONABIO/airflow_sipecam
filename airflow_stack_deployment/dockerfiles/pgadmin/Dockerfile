FROM dpage/pgadmin4:latest
MAINTAINER ixime

USER root

ARG NEWUID=1010
ARG NEWGID=1090

RUN OLDUID=$(id -u pgadmin) && \
    OLDGID=$(id -g pgadmin) && \
    usermod -u ${NEWUID} pgadmin && \
    groupmod -g ${NEWGID} pgadmin && \
    find / -xdev -group $OLDGID -exec chgrp -h pgadmin {} \; && \
    find / -xdev -user $OLDUID -exec chown -h pgadmin {} \;

RUN chown -R pgadmin:pgadmin /var/lib/pgadmin

USER pgadmin
