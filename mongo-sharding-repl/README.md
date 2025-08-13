# mongo-sharding

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Инициализируем конфигурационный сервер и шарды

```shell
./scripts/mongo-sharding-repl-init.sh
```

## Как проверить

Запускаем вывод количества записей на шардах

```shell
./scripts/mongo-sharding-repl-test.sh
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