FROM alpine:edge

RUN apk add --no-cache postgresql postgresql-contrib

ENV PGDATA=/var/lib/data/postgres
ENV LANG=en_US.utf8

EXPOSE 5432

RUN mkdir -p $PGDATA /run/postgresql /etc/postgres \
    && chown postgres:postgres $PGDATA /run/postgresql /etc/postgres

USER postgres

RUN pg_ctl initdb -o "--locale=$LANG"

VOLUME $PGDATA

ENTRYPOINT ["postgres",  "-c", "config_file=/etc/postgres.conf"]

COPY postgres.hba /etc/postgres.hba
COPY postgres.conf /etc/postgres.conf
