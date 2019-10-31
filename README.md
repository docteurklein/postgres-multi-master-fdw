# multi-master postgres

## how?

```sh
openssl rand -base64 32 > postgres_password
docker-compose up -d

docker-compose exec postgres1 psql -c "alter user postgres with password '$(cat postgres_password)'"
docker-compose exec postgres1 psql -f /etc/schema.sql

docker-compose exec postgres2 psql -c "alter user postgres with password '$(cat postgres_password)'"
docker-compose exec postgres2 psql -f /etc/schema.sql

export PGHOST=0 PGUSER=postgres PGPASSWORD="$(cat postgres_password)"
export PGPORT1=$(docker port postgres-multi-master-fdw_postgres1_1 5432/tcp |cut -d':' -f 2)
export PGPORT2=$(docker port postgres-multi-master-fdw_postgres2_1 5432/tcp |cut -d':' -f 2)

parallel ::: \
    "psql -p $PGPORT1 --quiet cluster -c 'insert into test(id, test) select i, random()::text from generate_series(1, 100000) i'" \
    "psql -p $PGPORT2 --quiet cluster -c 'insert into test(id, test) select i, random()::text from generate_series(1, 100000) i'"
```
