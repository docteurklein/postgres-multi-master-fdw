\c postgres
drop database if exists cluster;
create database cluster;
\c cluster;

set enable_partitionwise_join = true;
set enable_partitionwise_aggregate = true;

create extension postgres_fdw;

create server node_0 foreign data wrapper postgres_fdw options (dbname 'cluster', host 'postgres1', use_remote_estimate 'true', fetch_size '100000');
create server node_1 foreign data wrapper postgres_fdw options (dbname 'cluster', host 'postgres2', use_remote_estimate 'true', fetch_size '100000');

create user mapping for postgres server node_0 options (user 'postgres', password 'SjDv31vGhcAHKNkx4CVTvNkT59/Kide30WhjgDOzz2c=');
create user mapping for postgres server node_1 options (user 'postgres', password 'SjDv31vGhcAHKNkx4CVTvNkT59/Kide30WhjgDOzz2c=');

create table test (
    id bigint not null,
    test text not null
) partition by hash (id);

create table test_node_0_shard_0 (like test);
create table test_node_0_shard_1 (like test);
create table test_node_1_shard_0 (like test);
create table test_node_1_shard_1 (like test);

create foreign table foreign_test_node_0_shard_0
       partition of test for values with (modulus 4, remainder 0)
       server node_0 options(table_name 'test_node_0_shard_0')
;
create foreign table foreign_test_node_0_shard_1
       partition of test for values with (modulus 4, remainder 1)
       server node_0 options(table_name 'test_node_0_shard_1')
;
create foreign table foreign_test_node_1_shard_0
       partition of test for values with (modulus 4, remainder 2)
       server node_1 options(table_name 'test_node_1_shard_0')
;
create foreign table foreign_test_node_1_shard_1
       partition of test for values with (modulus 4, remainder 3)
       server node_1 options(table_name 'test_node_1_shard_1')
;
