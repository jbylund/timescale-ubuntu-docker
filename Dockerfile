FROM ubuntu:rolling

ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV PGDATA=/pgdata

RUN apt-get update > /dev/null && \
    apt-get dist-upgrade -y > /dev/null && \
    apt-get install -y \
        axel \
        bash-completion \
        build-essential \
        cmake \
        curl \
        ca-certificates \
        gnupg \
        gosu \
        libpq-dev \
        libssl-dev \
        libkrb5-dev \
        ripgrep \
        wget \
        > /dev/null && \
    curl --silent https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ groovy-pgdg main 13" | tee /etc/apt/sources.list.d/postgres-groovy-13.list && \
    apt-get update > /dev/null && \
    apt-get autoremove --purge -y > /dev/null && \
    apt-get clean -y > /dev/null && \
    apt-get autoclean -y > /dev/null

RUN apt-get install -y \
        pgxnclient \
        postgresql-plpython3-13 \
        postgresql-server-dev-13 \
    > /dev/null && \
    apt-get dist-upgrade -y > /dev/null

ENV CURLFLAGS="--silent --location"
RUN curl $CURLFLAGS https://raw.githubusercontent.com/docker-library/postgres/master/13/docker-entrypoint.sh | \
perl -pe 's#docker_process_init_files /docker-entrypoint-initdb#docker_process_init_files /timescale-initdb.d/* /docker-entrypoint-initdb#' > /usr/local/bin/docker-entrypoint.sh
RUN mkdir -p /docker-entrypoint-initdb.d/ /timescale-initdb.d/

RUN curl $CURLFLAGS https://raw.githubusercontent.com/timescale/timescaledb-docker/master/docker-entrypoint-initdb.d/000_install_timescaledb.sh > /timescale-initdb.d/05_install_timescaledb.sh
RUN curl $CURLFLAGS https://raw.githubusercontent.com/timescale/timescaledb-docker/master/docker-entrypoint-initdb.d/001_timescaledb_tune.sh > /timescale-initdb.d/10_timescaledb_tune.sh

COPY 0001_install_timescale.sh /tmp/01_install_timescale.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh /timescale-initdb.d/05_install_timescaledb.sh

ENV PATH="/usr/lib/postgresql/13/bin:/usr/local/go/bin:$PATH"

RUN bash /tmp/01_install_timescale.sh

ENV GOPATH=/root/go

ENTRYPOINT ["docker-entrypoint.sh"]
