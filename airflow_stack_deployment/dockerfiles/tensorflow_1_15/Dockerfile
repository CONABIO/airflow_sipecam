FROM ixws/tf-gpu:pip3.6-tf1.15-ub18.04
MAINTAINER ixime

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_CTYPE=C.UTF-8
ENV LC_MESSAGES=C.UTF-8
ARG DEBIAN_FRONTEND="noninteractive"

ARG AIRFLOW_VERSION="1.10.9"
ENV AIRFLOW_VERSION=${AIRFLOW_VERSION}

ARG AIRFLOW_USER_HOME=/usr/local/airflow
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}

ARG AIRFLOW_DEPS=""
ARG PYTHO_DEPS=""

ARG NEWUID=1010
ARG NEWGID=1090

RUN set -ex \
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yq \
    && apt-get upgrade -yq \
    && apt-get install -yq software-properties-common \
        $buildDeps \
        freetds-bin \
        build-essential \
        apt-utils \
        curl \
        rsync \
        netcat \
        python \
        augeas-tools \
        sudo \
        htop \
        nano \
        postgresql-client

RUN groupadd -g ${NEWGID} airflow && \
    useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} -g airflow -u ${NEWUID} -o -c "" -m airflow && \
    echo "airflow ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo) && \
    usermod -aG sudo airflow

RUN pip --no-cache-dir install apache-airflow[crypto,celery,postgres${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} && \
    pip --no-cache-dir install redis==3.2 && \
    pip --no-cache-dir install flask_bcrypt && \
    pip --no-cache-dir install SQLAlchemy==1.3.15

RUN apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg

RUN chown -R airflow: ${AIRFLOW_USER_HOME}
RUN chown airflow: /entrypoint.sh && chmod +x /entrypoint.sh
RUN mkdir -p /script && \
    chown -R airflow: /script

EXPOSE 8080 5555 8793 6006

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]
