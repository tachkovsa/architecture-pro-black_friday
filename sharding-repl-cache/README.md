# mongo-sharding

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Инициализируем конфигурационный сервер и шарды

```shell
./scripts/mongo-sharding-repl-cache-init.sh
```

## Как проверить

Запускаем вывод количества записей на шардах

```shell
./scripts/mongo-sharding-repl-cache-test.sh
```

Должны получить вывод следующего вида, где 1000 - это общее количество записей, 508 - количество записей на первом шарде, 492 - количество записей на втором шарде, также присуствует информация о количестве реплик на каждом шарде

```log
[direct: mongos] test> switched to db somedb
[direct: mongos] somedb> Documents total count: 1000
[direct: mongos] somedb> 
[direct: mongos] somedb> 
shard1 [direct: primary] test> Replicas count: 3
shard1 [direct: primary] test> 
shard2 [direct: primary] test> Replicas count: 3
shard2 [direct: primary] test> 
shard1 [direct: primary] test> switched to db somedb
shard1 [direct: primary] somedb> Documents on current shard: 508
shard1 [direct: primary] somedb> 
shard2 [direct: primary] test> switched to db somedb
shard2 [direct: primary] somedb> Documents on current shard: 492
shard2 [direct: primary] somedb> 
```

Открываем URL http://localhost:8080/, проверяем, что `cache_enabled` равен `true`:
```json
{
  "mongo_topology_type": "Sharded",
  "mongo_replicaset_name": null,
  "mongo_db": "somedb",
  "read_preference": "Primary()",
  "mongo_nodes": [
    [
      "mongos_router",
      27020]
  ],
  "mongo_primary_host": null,
  "mongo_secondary_hosts": [],
  "mongo_is_primary": true,
  "mongo_is_mongos": true,
  "collections": {
    "helloDoc": {
      "documents_count": 1000
    }
  },
  "shards": {
    "shard1": "shard1/shard1-1:27018,shard1-2:27021,shard1-3:27022",
    "shard2": "shard2/shard2-1:27019,shard2-2:27023,shard2-3:27024"
  },
  "cache_enabled": true,
  "status": "OK"
}
```

Делаем запрос к http://localhost:8080/helloDoc/users, фиксируем время ответа, после чего делаем повторный запрос на тот же адрес и фиксируем время ответа - оно должно быть меньше.
