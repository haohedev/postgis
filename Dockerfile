FROM postgres:10

ENV POSTGIS_MAJOR 2.5
ENV POSTGIS_VERSION 2.5.3+dfsg-2.pgdg90+1

RUN apt-get update \
    && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
    && apt-get install -y --no-install-recommends \
        postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
        postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
    && apt-get install -y python3 postgresql-plpython3-10 \
    && apt-get install -y python3-pip \
    && apt-get install -y wget lsb-core apt-transport-https \
    && sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/debian/ `lsb_release -c -s` main' > /etc/apt/sources.list.d/timescaledb.list" \
    && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | apt-key add - \
    && apt-get update \
    && apt-get install -y timescaledb-postgresql-10 \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip
RUN timescaledb-tune -yes
RUN service postgresql restart
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin

