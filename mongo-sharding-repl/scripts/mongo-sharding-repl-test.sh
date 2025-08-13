#!/bin/bash

###
# Проверка на роутере
###
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb;
print("Documents total count:", db.helloDoc.countDocuments());
exit();
EOF
echo

###
# Проверка количества реплик
###
docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
print("Replicas count:", rs.status().members.length);
exit();
EOF
echo

docker compose exec -T shard2-1 mongosh --port 27019 --quiet <<EOF
print("Replicas count:", rs.status().members.length);
exit();
EOF
echo

###
# Проверка на первом шарде
###
docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
use somedb;
print("Documents on current shard:", db.helloDoc.countDocuments());
exit();
EOF
echo

###
# Проверка на втором шарде
###
docker compose exec -T shard2-1 mongosh --port 27019 --quiet <<EOF
use somedb;
print("Documents on current shard:", db.helloDoc.countDocuments());
exit();
EOF
echo
